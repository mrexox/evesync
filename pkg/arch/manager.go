package main

// This package is to become a shaed object file
// It's goint to have these public symbols:

// Manager      - variable, implements Manager interface

import (
	"errors"
	"github.com/fsnotify/fsnotify"
	"github.com/mrexox/sysmoon/pkg"
	"io"
	"log"
	"os"
	"regexp"
	"strings"
)

type manager struct {
	command     string
	installKeys string
	deleteKeys  string
	logfile     string
}

var Manager = manager{
	command:     "pacman",
	installKeys: "-Sy",
	deleteKeys:  "-Ry",
	logfile:     "/var/log/pacman.log",
}

func (m manager) Install(pkg pkg.Package) error {
	return errors.New("Not implemented")
}

func (m manager) Delete(pkg pkg.Package) error {
	return errors.New("Not implemented")
}

func (m manager) Update(pkg pkg.Package) error {
	return errors.New("Not implemented")
}

var packageWatcher *pkg.PackageWatcher = nil

func (m manager) NewWatcher() (*pkg.PackageWatcher, error) {
	// Protect ourselves from initializing more than once
	if packageWatcher != nil {
		return packageWatcher, nil
	}
	events := make(chan *pkg.PackageEvent)
	errors := make(chan error)

	// if m.logfile does not exist
	// return nil, error!
	go watchPkgEvents(m.logfile, events, errors)

	var w *pkg.PackageWatcher
	w = &pkg.PackageWatcher{
		Events: events,
		Errors: errors,
	}
	packageWatcher = w
	return w, nil
}

func watchPkgEvents(logfile string, evs chan *pkg.PackageEvent, errs chan error) {
	w, err := fsnotify.NewWatcher()
	if err != nil {
		log.Fatal(err)
	}

	// Watching logfile changes
	w.Add(logfile)

	for {
		select {
		case ev, ok := <-w.Events:
			log.Println(ev)
			if ok {
				// Handle event
				pkgEv, err := handlePkgEvent(ev)

				if err != nil {
					errs <- err // filling errors
				} else {
					evs <- pkgEv // filling events
				}
			} else {
				errs <- errors.New("fsnotify failed for logfile events")
			}
		}

	}
}

func handlePkgEvent(event fsnotify.Event) (*pkg.PackageEvent, error) {
	var t pkg.PackageEventType
	var p *pkg.Package
	var pe *pkg.PackageEvent

	// Opening logfile and seeking to the
	file, err := os.Open(event.Name)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	lastLine := readLastLine(file)

	// Preparing package event
	t, p = determineChange(lastLine)
	if t != pkg.Nil && p != nil {
		pe = &pkg.PackageEvent{
			Type:    t,
			Package: p,
		}
	}

	return pe, nil
}

func readLastLine(file *os.File) string {
	buffsize := 100
	buffer := make([]byte, buffsize) // 200 should be enough (actually 60)
	for {
		file.Seek(0, 2) // Seeking the end of file
		_, err := file.Read(buffer)

		// If we are too far from end of file
		if err != io.EOF {
			file.Seek(0, 2)
			buffsize = buffsize + 100
			buffer = make([]byte, buffsize)
			continue
		}

		// Returning the last readed line slice
		str := string(buffer)
		if strings.Contains(str, "\n") {
			sl := strings.Split(str, "\n")
			return sl[len(sl)-1]
		}

		// Increasing buffer, it sould capture the newline
		buffsize = buffsize + 100
		buffer = make([]byte, buffsize)
	}

}

func determineChange(line string) (pkg.PackageEventType, *pkg.Package) {
	var t pkg.PackageEventType
	var p *pkg.Package

	if strings.Contains(line, "installed") {
		t = pkg.Install
	} else if strings.Contains(line, "reinstalled") {
		t = pkg.Update
	} else if strings.Contains(line, "removed") {
		t = pkg.Delete
	} else {
		// Not informative string
		return pkg.Nil, nil
	}

	reg := *regexp.MustCompile(`\s+(?P<name>[^\s]+)\s+\((?P<version>[^()]+)\)`)
	res := reg.FindStringSubmatch(line)
	p = &pkg.Package{
		Name:    res[1],
		Version: res[2],
	}

	return t, p
}
