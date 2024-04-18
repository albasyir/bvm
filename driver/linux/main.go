package linux

import "fmt"

func init() {
	fmt.Println("Build Using Linux")
}

type LinuxDriver struct {
	version string
}

func (driver LinuxDriver) GetCurrentVersion() string {
	return "0.1"
}
