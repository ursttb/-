from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():
    #启动一个乌龟节点
    turtle =  Node(package="turtlesim", executable="turtlesim_node")
    #启动spawn节点召唤第二只乌龟
    spawn =  Node(package="turtle_follows", executable="spawn", parameters=[{"turtle_name":"t2"}])
    #广播两只乌龟相对world的坐标变换
    broadcaster1 = Node(package="turtle_follows", executable="tf_broadcaster", name="broad1")
    broadcaster2 = Node(package="turtle_follows", executable="tf_broadcaster", name="broad2", parameters=[{"turtle":"t2"}])
    #创建监听节点
    listener = Node(package="turtle_follows", executable="tf_listener", 
    		    parameters=[{"father_frame":"t2", "child_frame":"turtle1"}])
    return LaunchDescription([turtle ,spawn,broadcaster1,broadcaster2,listener])

