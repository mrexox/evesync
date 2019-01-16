package pkg

type Package struct {
	name    string
	version string
}

func UpdatedPackages() []Package {
	var packages = []Package{}

	// Parse package updates
	packages = updated()

	// Return the `diff` from packages of database
	packages = filterNew(packages)

	return packages
}

func updated() []Package {
	// Call special package function
	return []Package{}
}

func filterNew(packages []Package) []Package {
	// Database query
	// Get only those that are not installed already
	// Update database (use channels?)
	return []Package{}
}
