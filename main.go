package main

import (
	"flag"
	"github.com/fsnotify/fsnotify"
	"github.com/gin-gonic/gin"
	"github.com/robfig/cron/v3"
	"github.com/spf13/viper"
	"log"
	"os/exec"
)

var env = flag.String("env", "prd", "环境")
var fPath = flag.String("path", "./config", "环境")

type Rank4Config struct {
	CronCheck struct {
		Services []struct {
			Spec string
			Bin  string
			Path string
			Conf string
		}
	} `mapstructure:"rank4_cron_check"`
}

var CronIds []cron.EntryID
var V *viper.Viper

func main() {
	arr := [2]int{1, 2}
	res := []int{}
	for i, v := range arr {
		log.Printf("%v", &v, &i)
		res = append(res, v)
	}
	log.Println("res:", res)
	flag.Parse()
	c := cron.New()
	V = initConfigure(c)
	addCronCheck(c)
	getConfigServices()
	select {}
}
func getConfigServices() {
	r := gin.Default()
	r.GET("/getConfig", func(c *gin.Context) {
		c.YAML(200, gin.H{
			"rank4_cron_check": V.GetStringMap("rank4_cron_check"),
		})
	})
	go r.Run(":18666") // listen and serve on 0.0.0.0:8080

}

func addCronCheck(c *cron.Cron) {
	var cfg Rank4Config
	V.Unmarshal(&cfg)
	CronIds = CronIds[:0]
	for _, v := range cfg.CronCheck.Services {
		spec := v.Spec
		path := v.Path
		bin := v.Bin
		id, err := c.AddFunc(spec, func() {
			checkBin := "cd " + path + " && " + "sh control.sh start " + bin + " " + *env + " ./conf/server.xml"
			log.Println(checkBin)
			cmd := exec.Command("sh", "-c", checkBin)
			err := cmd.Start()
			if err != nil {
				log.Fatalf("cmd.Run() sh failed with %s\n", err)
			}
			err = cmd.Wait() //等待执行完成
			if nil != err {
				log.Println("cmd wait", err)
			}
		})
		if err != nil {
			log.Println("cron add err", err)
		}
		CronIds = append(CronIds, id)
	}
	c.Start()
}

func initConfigure(c *cron.Cron) *viper.Viper {
	v := viper.New()
	v.SetConfigName(*env)   // 设置文件名称（无后缀）
	v.SetConfigType("yaml") // 设置后缀名 {"1.6以后的版本可以不设置该后缀"}
	v.AddConfigPath(*fPath) // 设置文件所在路径
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
		for _, id := range CronIds {
			c.Remove(id)
		}

		addCronCheck(c)
	})
	return v
}
