# webrtc2sip kubernetes

From this repository you will be able to build docker container with [webrtc2sip](https://github.com/DoubangoTelecom/webrtc2sip) and deploy it to kubernetes.

Docker container contains supervisord and supervisor-stdout which is redirecting everything to screen/main docker process output and making them available in kubectl logs and other logging solutions like azure log analytics.

This will deploy webrtc websocket proxy to sip. Allowing you to use any SIP server provider (twilio, cloudtalk...) for making calls.

# build and deployment

```
docker build -t webrtc2sip:latest .
docker push webrtc2sip:latest
```

1. Change `image:` in [kubernetes-deployment.yaml](kubernetes-deployment.yaml)
2. All deployments to kubernetes will be made to `webrtc2sip` namespace so we need to create it: `kubectl create ns webrtc2sip`
3. Create secret / sync from vault to kubernetes secrets with name `webrtc2sip-cert` which needs to contain `tls.key` and `tls.crt` files.
4. Create config with `webrtc2sip` config xml file. `kubectl create configmap webrtc2sip-config --namespace webrtc2sip --from-file=config.xml`
5. Deploy it to kubernetes `kubectl apply -f kubernetes-deployment.yaml` and obtain external ip address form loadbalancer `kubectl get services -nwebrtc2sip` and set DNS records

TIP: You should add liveness and readiness probes to port 10062 (wss) or 10061 (ws) - be carefull a lot of logs will be printed so it may affect your pricing for log analytics.

# testing with frontend client

You can use clients like [sipML5](https://www.doubango.org/sipml5/call.htm?svn=252#) to test this proxy. 
With sipML5 you will need to use Expert Mode.


Enter all required data:


Private Entity: 111111111

Public Identity:  sip:111111111@voice.cloudtalk.sk

Password: XXXXXXX

Realm: voice.cloudtalk.sk



Expert mode settings:


WebSocket Server URL:  wss://YOUR_DNS:10062    (YOUR_DNS is domain name pointing to kubernetes loadbalancer created by this deployment)

SIP outbound Proxy URL: udp://voice.cloudtalk.sk:5060      (original SIP server from your provider)