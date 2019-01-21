package main

import (
	"github.com/mrexox/sysmoon/pkg"
	"log"
	"os"
	"plugin"
)

func main() {

	// get package watcher from sysmoon_manager.so file
	var pkgManager *Manager
	// TODO: using plugin...
	// ...
	pkgWatcher := pkgManager.NewWatcher()

	for {
		select {
		// Packages related events
		case event := <-pkgWatcher.Events:
			switch event.Type {
			case pkg.Update:
				log.Println("Updated package:", event.Package)
			case pkg.Install:
				log.Println("Installed package:", event.Package)
			case pkg.Delete:
				log.Println("Uninstalled package:", event.Package)

			}
		}
	}
}
