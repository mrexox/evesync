package main

// This package is to become a shaed object file
// It's goint to have these public symbols:

// Manager      - variable, implements Manager interface

import (
	"github.com/mrexox/sysmoon/pkg"
)

type manager struct {
	command     string
	installKeys string
	deleteKeys  string
	logfile     string
}

func (m manager) Install(pkg pkg.Package) error {
	return nil
}

func (m manager) Delete(pkg pkg.Package) error {
	return nil
}

func (m manager) Update(pkg pkg.Package) error {
	return nil
}

var Manager = manager{
	command:     "pacman",
	installKeys: "-Sy",
	deleteKeys:  "-Ry",
	logfile:     "/var/log/pacman.log",
}

var packageWatcher *pkg.PackageWatcher = nil

func (m manager) NewWatcher() (*pkg.PackageWatcher, error) {
	// Protect ourselves from initializing more than once
	if packageWatcher != nil {
		return packageWatcher, nil
	}
	// TODO: Create channels
	// TODO: Start goroutines
	// TODO: Initialize PackageWatcher
	var w *pkg.PackageWatcher
	w = &pkg.PackageWatcher{
		// TODO: fill me
	}
	packageWatcher = w
	return w, nil
}
