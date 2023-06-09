    #!/bin/sh

function change() {

    # currentImageVersion=$2

    #grep 

    oldImageId=`docker images -q registry.aishu.cn:15000/autosheets/${imageName}`
    docker pull acr.aishu.cn/autosheets/${imageName}:${currentImageVersion}
    echo '=================需要删除以前拉取的tag包含7.0.4.6的镜像=================='
    newImageId=`docker images -q acr.aishu.cn/autosheets/${imageName}`
    echo '=============新镜像信息============='
    docker images | egrep ${currentImageVersion} | awk '{print $0}'

    echo '=======开始替换流程======='
    docker tag ${newImageId} registry.aishu.cn:15000/autosheets/${imageName}:$2
    docker push registry.aishu.cn:15000/autosheets/${imageName}:$2
    # docker rmi -f acr.aishu.cn/autosheets/${imageName}:${currentIgeVersion}

    runningContaineId=`docker ps -q --filter name=$3 --filter status=running`
    echo '要停止的容器名称为--->'$3
    echo '要停止的容器编号为--->'${runningContaineId}
    docker stop ${runningContaineId}
    echo '被删除镜像ID为--->'${oldImageId}
    docker rmi -f ${oldImageId}
    echo '=======替换流程结束======='
}

serviceName=$1
runningImageVersion=`docker images | grep transformation | awk '{print $2}'`
currentImageVersion=$2

imageName=""

case $serviceName in 
    autosheets)
        echo "替换前端镜像"
        imageName="autosheets"
        runningContainerName='k8s_autosheets_autosheets'
        change ${imageName} ${runningImageVersion} ${runningContainerName}
    ;;
    ss)
        echo "替换后端镜像"
        imageName="sheet"
        runningContainerName='k8s_sheet_sheet'
        change ${imageName} ${runningImageVersion} ${runningContainerName}
    ;;
    ts)
        echo "替换文件上传服务镜像"
        imageName="transformation"
        runningContainerName='k8s_transformation_transformation'
        change ${imageName} ${runningImageVersion} ${runningContainerName}
    ;;
    cs)
        echo "替换协作服务镜像"
        imageName="collaboration"
        runningContainerName='k8s_collaboration_collaboration'
       change ${imageName} ${runningImageVersion} ${runningContainerName}
    ;;
    console)
        echo "替换控制台服务镜像"
        imageName="autosheets-console"
        runningContainerName='k8s_sheet-policy_sheet-policy'
        change ${imageName} ${runningImageVersion} ${runningContainerName}
    ;;
    policy)
        echo "替换policy服务镜像"
        imageName="autosheets"
        runningContainerName='k8s_autosheets_autosheets'
        change ${imageName} ${runningImageVersion} ${runningContainerName}
    ;;
    *)
        echo "没有这个服务"
        exit;
esac