package main

import (
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"sync"
	"time"
)

type Store struct {
	mu    sync.RWMutex
	path  string
	state State
}

func newStore(path string) (*Store, error) {
	store := &Store{path: path}
	data, err := os.ReadFile(path)
	if errors.Is(err, os.ErrNotExist) {
		store.state = defaultState()
		if err := store.persistLocked(store.state); err != nil {
			return nil, err
		}
		return store, nil
	}
	if err != nil {
		return nil, err
	}
	if err := json.Unmarshal(data, &store.state); err != nil {
		return nil, err
	}
	if store.state.SchemaVersion == 0 {
		store.state.SchemaVersion = SchemaVersion
	}
	if store.state.Settings.DefaultHTTPPort == 0 {
		store.state.Settings = defaultState().Settings
	}
	if store.state.Rules == nil {
		store.state.Rules = []ProxyRule{}
	}
	if store.state.Certificates == nil {
		store.state.Certificates = []CertificateMeta{}
	}
	if err := validateState(store.state); err != nil {
		return nil, err
	}
	return store, nil
}

func (s *Store) Snapshot() State {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return cloneState(s.state)
}

func (s *Store) Update(fn func(*State) error) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	next := cloneState(s.state)
	if err := fn(&next); err != nil {
		return err
	}
	next.SchemaVersion = SchemaVersion
	next.UpdatedAt = time.Now().UTC()
	if err := validateState(next); err != nil {
		return err
	}
	if err := s.persistLocked(next); err != nil {
		return err
	}
	s.state = next
	return nil
}

func (s *Store) Replace(next State) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	next.SchemaVersion = SchemaVersion
	next.UpdatedAt = time.Now().UTC()
	if err := validateState(next); err != nil {
		return err
	}
	if err := s.persistLocked(next); err != nil {
		return err
	}
	s.state = cloneState(next)
	return nil
}

func (s *Store) persistLocked(state State) error {
	data, err := json.MarshalIndent(state, "", "  ")
	if err != nil {
		return err
	}
	return writeFileAtomic(s.path, append(data, '\n'), 0o600)
}

func writeFileAtomic(path string, data []byte, mode os.FileMode) error {
	if err := os.MkdirAll(filepath.Dir(path), 0o750); err != nil {
		return err
	}
	tmp, err := os.CreateTemp(filepath.Dir(path), ".tmp-*")
	if err != nil {
		return err
	}
	tmpName := tmp.Name()
	defer os.Remove(tmpName)
	if err := tmp.Chmod(mode); err != nil {
		tmp.Close()
		return err
	}
	if _, err := tmp.Write(data); err != nil {
		tmp.Close()
		return err
	}
	if err := tmp.Sync(); err != nil {
		tmp.Close()
		return err
	}
	if err := tmp.Close(); err != nil {
		return err
	}
	return os.Rename(tmpName, path)
}
