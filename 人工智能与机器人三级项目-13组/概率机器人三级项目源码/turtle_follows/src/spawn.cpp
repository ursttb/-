#include <chrono>
#include <memory>

#include "rclcpp/rclcpp.hpp"
#include "turtlesim/srv/spawn.hpp"//
#include "tf2_ros/transform_listener.h"//创建监听器的类型
#include "std_msgs/msg/string.hpp"
//1.使用参数服务声明新的乌龟的信息
//2.创建服务客户端
//3.连接服务端
//4.组织并发送数据

using namespace std::chrono_literals;

class Spawn : public rclcpp::Node
{
  public:
    Spawn(): Node("Spawn_node")
    {
	//1.使用参数服务声明新的乌龟的信息
	this->declare_parameter("x", 3.0);
	this->declare_parameter("y", 3.0);
	this->declare_parameter("theta", 0.0);
	this->declare_parameter("turtle_name", "turtle2");
	x = this->get_parameter("x").as_double();
	y = this->get_parameter("y").as_double();
	theta = this->get_parameter("theta").as_double();
	turtle_name = this->get_parameter("turtle_name").as_string();
	//2.创建服务客户端
	spawn_client_ = this->create_client<turtlesim::srv::Spawn>("/spawn");
    }
    //3.连接服务端
    bool connect_server()
    {
	while(!spawn_client_->wait_for_service(1s))
	{
	    if(!rclcpp::ok())
	    {
		RCLCPP_INFO(rclcpp::get_logger("rclcpp"), "强制退出!");
		return false;
	    }
	    RCLCPP_INFO(this->get_logger(), "服务连接中......");
	}		    
	return true;
    }
    
    //4.组织并发送数据
    rclcpp::Client<turtlesim::srv::Spawn>::FutureAndRequestId request()
    {
	auto req = std::make_shared<turtlesim::srv::Spawn::Request>();

	req->x = x;
	req->y = y;
	req->theta = theta;
	req->name = turtle_name;
	
	return spawn_client_->async_send_request(req);
    }
  private:
      double_t x, y, theta;
      std::string turtle_name;
      rclcpp::Client<turtlesim::srv::Spawn>::SharedPtr spawn_client_;
};

  int main(int argc, char * argv[])
  {
    rclcpp::init(argc, argv);
    //由于节点任务是发布参数服务，服务完就可以关闭了，因此不需要span函数
    //rclcpp::spin(std::make_shared<TF_listener>());    
    //创建自定义节点类对象，组织函数，处理响应结果
    auto client_ = std::make_shared<Spawn>();
    bool flag = client_->connect_server();
    if(!flag)
    {
	RCLCPP_INFO(rclcpp::get_logger("rclcpp"), "服务连接失败");
	return 1;
    }
    //发送请求
    auto response = client_->request();
    //处理响应
    if(rclcpp::spin_until_future_complete(client_, response) == rclcpp::FutureReturnCode::SUCCESS)
    {
	RCLCPP_INFO(client_->get_logger(), "响应成功！");
	std::string name = response.get()->name;
	if(name.empty())
	{
	    RCLCPP_INFO(client_->get_logger(), "生成的乌龟因为重名而生成失败！");
	}
	else
	{
	    RCLCPP_INFO(client_->get_logger(), "生成乌龟成功！");
	}
    }
    else
    {
	RCLCPP_INFO(client_->get_logger(), "响应失败！");
    }
    rclcpp::shutdown();
    return 0;
  }

