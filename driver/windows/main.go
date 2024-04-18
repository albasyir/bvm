package windows

import "fmt"

func init() {
	fmt.Println("Build Using Windows")
}

type WindowsDriver struct {
	version string
}

func (driver WindowsDriver) GetCurrentVersion() string {
	return "0.1"
}
