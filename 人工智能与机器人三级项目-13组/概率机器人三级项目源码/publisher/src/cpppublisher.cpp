#include <chrono>
#include <memory>

#include "rclcpp/rclcpp.hpp"
#include "std_msgs/msg/string.hpp"
#include "geometry_msgs/msg/twist.hpp"

#define PI 3.14159265358979323846

//topic:turtle1/cmd_vel message_type:[geometry_msgs/msg/Twist]

using namespace std::chrono_literals;

/* This example creates a subclass of Node and uses std::bind() to register a
* member function as a callback from the timer. */

class MinimalPublisher : public rclcpp::Node
{
  public:
    MinimalPublisher()//node
    : Node("minimal_publisher"), count_(0)
    {
      publisher_ = this->create_publisher<geometry_msgs::msg::Twist>("turtle1/cmd_vel", 10);//init
      timer_ = this->create_wall_timer(
      500ms, std::bind(&MinimalPublisher::timer_callback, this));
    }

  private:
    void timer_callback()
    {
      static int count = 0;
      geometry_msgs::msg::Twist speed;
	speed.linear.x = 1; // 设置线速度为1m/s，正为前进，负为后退
	speed.linear.y = 0;
	speed.linear.z = 0;
	speed.angular.x = 0;
	speed.angular.y = 0;
	speed.angular.z = 0; 

      count++;
      while(count == 5)
      {
          count=0;
          speed.linear.x = 1; 
	  speed.linear.y = 0;
	  speed.linear.z = 0;
	  speed.angular.x = 0;
	  speed.angular.y = 0;
          speed.angular.z = PI; //转90°
      }
      publisher_->publish(speed);
    }
    rclcpp::TimerBase::SharedPtr timer_;
    rclcpp::Publisher<geometry_msgs::msg::Twist>::SharedPtr publisher_;
    size_t count_;
  };

  int main(int argc, char * argv[])
  {
    rclcpp::init(argc, argv);
    rclcpp::spin(std::make_shared<MinimalPublisher>());
    rclcpp::shutdown();
    return 0;
  }

