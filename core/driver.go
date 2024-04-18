package core

import (
	"bvm/contract"
	"bvm/driver/linux"
)

func NewBVM() contract.Driver {
	driver := linux.LinuxDriver{}

	return driver
}
