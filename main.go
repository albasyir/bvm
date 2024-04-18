package main

import (
	"bvm/contract"
	"bvm/core"
	"fmt"
)

func main() {
	var driverInstance contract.Driver = core.NewBVM()
	bvmDriver, created := driverInstance.(contract.Driver)

	if !created {
		fmt.Println("Failed to assert Driver Instance")
		return
	}

	fmt.Println(bvmDriver.GetCurrentVersion())
}
