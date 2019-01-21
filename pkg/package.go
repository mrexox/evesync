package pkg

import (
	"github.com/fsnotify/fsnotify"
)

type Package struct {
	Name    string
	Version string
}

type PackageWatcher struct {
	Events chan PackageEvent
	Errors chan error
}

type Manager interface {
	NewWatcher() *PackageWatcher
	Install(pkg Package) error
	Delete(pkg Package) error
	Update(pkg Package) error
}

// Event
type PackageEvent struct {
	Type    PackageEventType
	Package *Package
}

// Simple integer constant
type PackageEventType uint32

const (
	Install PackageEventType = 1 + iota
	Update
	Delete
	Downgrade
)

// Implementing printable interface
func (pkg Package) String() string {
	return []string{pkg.Name, pkg.Version}.Join("-")
}

func (ev PackageEventType) String() (name string) {
	switch ev {
	case Install:
		name = "Install"
	case Update:
		name = "Update"
	case Delete:
		name = "Delete"
	case Downgrade:
		name = "Downgrade"
	case true:
		name = "<Unknown PackageEventType>"
	}
}
