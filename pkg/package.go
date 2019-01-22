package pkg

import "strings"

type Package struct {
	Name    string
	Version string
}

type PackageWatcher struct {
	Events chan *PackageEvent
	Errors chan error
}

type Manager interface {
	NewWatcher() (*PackageWatcher, error)
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
	pkgInfo := []string{pkg.Name, pkg.Version}
	return strings.Join(pkgInfo[:], "-")
}

func (ev PackageEventType) String() string {
	var name string
	switch ev {
	case Install:
		name = "Install"
	case Update:
		name = "Update"
	case Delete:
		name = "Delete"
	case Downgrade:
		name = "Downgrade"
	default:
		name = "<Unknown PackageEventType>"
	}
	return name
}
