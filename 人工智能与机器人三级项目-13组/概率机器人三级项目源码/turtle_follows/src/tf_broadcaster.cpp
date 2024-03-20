#include <chrono>
#include <memory>

#include "rclcpp/rclcpp.hpp"
#include "tf2_ros/transform_broadcaster.h"//创建动态广播器的类型
#include "turtlesim/msg/pose.hpp"//订阅乌龟1的pose话题
#include "geometry_msgs/msg/transform_stamped.hpp"//动态广播器能广播出去的话题类型
#include "tf2/LinearMath/Quaternion.h"//转换欧拉角--四元数
#include "std_msgs/msg/string.hpp"


using namespace std::chrono_literals;

class TF_broadcaster : public rclcpp::Node
{
  public:
    TF_broadcaster(): Node("TF_broadcaster")
    {
      this->declare_parameter("turtle", "turtle1");
      turtle = this->get_parameter("turtle").as_string();//乌龟名字动态获取
      
      broadcaster_ = std::make_shared<tf2_ros::TransformBroadcaster>(this);//创建一个广播器
      pose_sub_ = this->create_subscription<turtlesim::msg::Pose>("/" + turtle + "/pose", 10, 
		std::bind(&TF_broadcaster::do_pose,this,std::placeholders::_1));//订阅乌龟1位姿关系
    }

  private:
    std::string turtle;
    void do_pose(const turtlesim::msg::Pose &pose)
    {
	geometry_msgs::msg::TransformStamped ts;//获取乌龟1位姿相对world的关系并发布
	ts.header.stamp = this->now();
	ts.header.frame_id = "world";
	
	ts.child_frame_id = turtle;
	
	ts.transform.translation.x = pose.x;
	ts.transform.translation.y = pose.y;
	ts.transform.translation.z = 0.0;
	
	tf2::Quaternion qtn;
	qtn.setRPY(0, 0, pose.theta);
        ts.transform.rotation.x = qtn.x();
        ts.transform.rotation.y = qtn.y();
        ts.transform.rotation.z = qtn.z();
        ts.transform.rotation.w = qtn.w();
	
	broadcaster_->sendTransform(ts);
    }
    std::shared_ptr<tf2_ros::TransformBroadcaster> broadcaster_;
    rclcpp::Subscription<turtlesim::msg::Pose>::SharedPtr pose_sub_;

  };

  int main(int argc, char * argv[])
  {
    rclcpp::init(argc, argv);
    rclcpp::spin(std::make_shared<TF_broadcaster>());
    rclcpp::shutdown();
    return 0;
  }

