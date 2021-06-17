package main

import (
	"flag"
	"github.com/fsnotify/fsnotify"
	"github.com/gin-gonic/gin"
	"github.com/robfig/cron/v3"
	"github.com/spf13/viper"
	"log"
	"os/exec"
	"syscall"
)

var config *viper.Viper
var env = flag.String("env", "prd", "环境")

type Rank4Config struct {
	//Ecs []map[string]string this works for ecs with name
	CronCheck struct {
		Services []struct {
			Spec string
			Bin  string
			Path string
			Conf string
		}
	} `mapstructure:"cron_check"`
	//Services []map[string][]string
}

var C Rank4Config

func main() {
	config = initConfigure()
	config.Unmarshal(&C)

	r := gin.Default()
	r.GET("/getConfig", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"config": config.AllSettings(),
		})
	})
	go r.Run(":18666") // listen and serve on 0.0.0.0:8080

	i := 0
	c := cron.New()
	for _, v := range C.CronCheck.Services {
		cmd := exec.Command("sh", v.Path, " status ", v.Bin, *env, v.Conf)
		out, err := cmd.CombinedOutput()
		if err != nil {
			log.Fatalf("cmd.Run() sh failed with %s\n", err)
		}
		err = cmd.Wait() //等待执行完成
		if nil != err {
			log.Println("cmd wait",err)
		}
		log.Println("Exit Code", cmd.ProcessState.Sys().(syscall.WaitStatus).ExitStatus())
		log.Printf("combined cntrol out:\n%s\n", string(out))
	}
	spec := "*/1 * * * *"    // 每一分钟，
	c.AddFunc(spec, func() {
		i++
		log.Println("cron running:", i)
	})
	c.Start()
	select{}
}

func initConfigure() *viper.Viper {
	v := viper.New()
	v.SetConfigName(*env) // 设置文件名称（无后缀）
	v.SetConfigType("yaml")   // 设置后缀名 {"1.6以后的版本可以不设置该后缀"}
	v.AddConfigPath("./config/")  // 设置文件所在路径
	// v.Set("verbose", true) // 设置默认参数

	if err := v.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); ok {
			panic(" Config file not found; ignore error if desired")
		} else {
			panic("Config file was found but another error was produced")
		}
	}
	// 监控配置和重新获取配置
	v.WatchConfig()

	v.OnConfigChange(func(e fsnotify.Event) {
		log.Println("Config file changed:", e.Name)
	})
	return v
}
