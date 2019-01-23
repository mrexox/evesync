package main

import (
	"github.com/mrexox/sysmoon/pkg"
	"log"
	"plugin"
)

func main() {

	// get package watcher from sysmoon_manager.so file
	// FIXME: change to global path (or read from config)
	distroPlugin, err := plugin.Open("sysmoon_distro.so")
	if err != nil {
		log.Fatal(err)
	}
	pkgManager, err := distroPlugin.Lookup("Manager")
	if err != nil {
		log.Fatal(err)
	}
	pkgWatcher, err := pkgManager.(pkg.Manager).NewWatcher()

	// TODO: also add some config files watchers

	// TODO: implement handlers
	// TODO: implement data storage service

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
