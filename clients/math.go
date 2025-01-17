package main

import (
	"fmt"
	"github.com/sirupsen/logrus"
	"io"
	neturl "net/url"
	"openziti-test-kitchen/appetizer/clients/common"
	"os"
	"strings"
)

func main() {
	if len(os.Args) < 6 {
		fmt.Printf("Insufficient arguments provided\n\nUsage: ./math <serviceName> <identityFile> input1 operator input2\n\n")
		return
	}
	url := os.Args[1]
	if !strings.HasPrefix(url, "http://") {
		url = "http://" + url
	}

	input1 := os.Args[3]
	operator := os.Args[4]
	input2 := os.Args[5]
	url = fmt.Sprintf("%s/domath?input1=%s&operator=%s&input2=%s", url, input1, neturl.QueryEscape(operator), input2)

	logrus.Infof("Connecting to secure service at: '%s'", url)
	resp, err := common.NewZitiClient(os.Args[2]).Get(url)
	if err != nil {
		logrus.Fatal(err)
	}

	_, err = io.Copy(os.Stdout, resp.Body)
	if err != nil {
		logrus.Fatal(err)
	}
}
