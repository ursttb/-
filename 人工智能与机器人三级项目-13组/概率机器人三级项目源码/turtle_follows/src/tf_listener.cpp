#include <chrono>
#include <memory>

#include "rclcpp/rclcpp.hpp"
#include "tf2_ros/buffer.h"//缓存器,可以对多个广播器的内容进行存储
#include "tf2_ros/transform_listener.h"//创建监听器的类型
#include "geometry_msgs/msg/twist.hpp"
#include "std_msgs/msg/string.hpp"


using namespace std::chrono_literals;

class TF_listener : public rclcpp::Node
{
  public:
    TF_listener(): Node("TF_listener")
    {
        //声明参数服务
        this->declare_parameter("father_frame", "turtle2");
        this->declare_parameter("child_frame", "turtle1");
        father_frame = this->get_parameter("father_frame").as_string();
        child_frame = this->get_parameter("child_frame").as_string();
        
    	buffer_ = std::make_unique<tf2_ros::Buffer>(this->get_clock());
	listener_ = std::make_shared<tf2_ros::TransformListener>(*buffer_, this);
	timer_ = this->create_wall_timer(1s, std::bind(&TF_listener::on_timer, this));
	cmd_pub_ = this->create_publisher<geometry_msgs::msg::Twist>("/" + father_frame + "/cmd_vel", 10);
    }

  private:
    void on_timer()
    {
	try
	{
	    //实现坐标变换
	    auto ts = buffer_->lookupTransform(father_frame, child_frame, tf2::TimePointZero);
	    RCLCPP_INFO(this->get_logger(), "坐标转换完成");
	    RCLCPP_INFO(this->get_logger(), 
	    			"frame:%s, child_frame:%s,偏移量(%0.2f, %0.2f, %0.2f)", 
	    			ts.header.frame_id.c_str(),
	    			ts.child_frame_id.c_str(),
	    			ts.transform.translation.x,
	    			ts.transform.translation.y,
	    			ts.transform.translation.z);
	    //组织并发布速度指令
	    geometry_msgs::msg::Twist twist;
	    
	    twist.linear.x = 0.5 * sqrt( pow(ts.transform.translation.x, 2) + pow(ts.transform.translation.y, 2)); 
	    twist.angular.z = 1.0 * atan2(ts.transform.translation.y, ts.transform.translation.x); 
	    
	    cmd_pub_->publish(twist);
	}
	catch(const tf2::LookupException& e)
	{
	    RCLCPP_INFO(this->get_logger(), "异常提示：%s", e.what());
	}
    }
    std::string father_frame;
    std::string child_frame;
    std::unique_ptr<tf2_ros::Buffer> buffer_;
    std::shared_ptr<tf2_ros::TransformListener> listener_;
    rclcpp::TimerBase::SharedPtr timer_;
    rclcpp::Publisher<geometry_msgs::msg::Twist>::SharedPtr cmd_pub_;

  };

  int main(int argc, char * argv[])
  {
    rclcpp::init(argc, argv);
    rclcpp::spin(std::make_shared<TF_listener>());
    rclcpp::shutdown();
    return 0;
  }

