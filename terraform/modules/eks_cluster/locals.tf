locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.eks_portfolio_cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.eks_portfolio_cluster.certificate_authority[0].data}
  name: ${aws_eks_cluster.eks_portfolio_cluster.name}
contexts:
- context:
    cluster: ${aws_eks_cluster.eks_portfolio_cluster.name}
    user: ${aws_eks_cluster.eks_portfolio_cluster.name}
  name: ${aws_eks_cluster.eks_portfolio_cluster.name}
current-context: ${aws_eks_cluster.eks_portfolio_cluster.name}
kind: Config
preferences: {}
users:
- name: ${aws_eks_cluster.eks_portfolio_cluster.name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/${var.kubeconfig_version}
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${aws_eks_cluster.eks_portfolio_cluster.name}"
KUBECONFIG


  aws_auth = <<AWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
${var.aws_auth}
AWSAUTH


  eks_admin = <<EKSADMIN
apiVersion: v1
kind: ServiceAccount
metadata:
  name: eks-admin
  namespace: kube-system

---

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: eks-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: eks-admin
  namespace: kube-system
EKSADMIN


  kube2iam = <<KUBE2IAM
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kube2iam
  namespace: kube-system
imagePullSecrets:
- name: dps-docker-creds
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kube2iam
  namespace: kube-system
rules:
  - apiGroups: [""]
    resources: ["namespaces","pods"]
    verbs: ["get","watch","list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kube2iam
  namespace: kube-system
subjects:
- kind: ServiceAccount
  name: kube2iam
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: kube2iam
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kube2iam
  namespace: kube-system
  labels:
    app: kube2iam
spec:
  selector:
    matchLabels:
      app: kube2iam
  updateStrategy:
    type: RollingUpdate
  template:
    metadata:
     labels:
       name: kube2iam
       app: kube2iam
    spec:
      serviceAccountName: kube2iam
      hostNetwork: true
      containers:
        - image: jtblin/kube2iam:0.11.1
          name: kube2iam
          args:
            - "--auto-discover-base-arn"
            - "--auto-discover-default-role"
            - "--iptables=true"
            - "--host-ip=$(HOST_IP)"
            - "--host-interface=${var.enable_calico ? "eni+" : "eni+"}"
            - "--node=$(NODE_NAME)"
          env:
            - name: HOST_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
            - name: NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
          ports:
            - containerPort: 8181
              hostPort: 8181
              name: http
          securityContext:
            privileged: true
KUBE2IAM

  eniplugins = <<ENIPLUGINS
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
  name: eu-west-2a
spec:
  securityGroups:
    - ${aws_security_group.cluster.id}
  subnet: ${aws_subnet.private-1a.id}
---
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
  name: eu-west-2b
spec:
  securityGroups:
    - ${aws_security_group.cluster.id}
  subnet: ${aws_subnet.private-1b.id}
ENIPLUGINS
}
