package main

import (
	"fmt"
	"github.com/mrexox/sysmoon/pkg"
	"time"
)

func main() {
	for {
		time.Sleep(1 * time.Second)
		fmt.Println("Woke up!")

		newPackages := pkg.UpdatedPackages()
		fmt.Printf("%+v\n", newPackages)

		fmt.Println("Going to sleep...")
	}
}
