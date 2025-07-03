
# 🌐 인프라 자동화 프로젝트 (Terraform 기반)

뉴스 구독 웹 서비스의 AWS 기반 클라우드 인프라를 Terraform으로 구성한 프로젝트입니다. IaC(Infrastructure as Code) 원칙에 따라 모듈화된 구조로 EKS, Lambda, RDS, VPC, 보안 설정 등을 자동으로 배포합니다.

---

## 🧱 주요 구성 요소

| 구성 요소 | 설명 |
|-----------|------|
| **EKS** | 애플리케이션이 배포되는 쿠버네티스 클러스터 |
| **Lambda** | 뉴스 수집 및 발송을 자동화하는 서버리스 함수 |
| **RDS (MySQL)** | 사용자, 키워드, 수신 이력 저장용 DB |
| **VPC/Subnet/NAT** | 퍼블릭/프라이빗 네트워크 구분, NAT 게이트웨이 포함 |
| **Security Group** | 리소스별 목적에 맞는 보안 그룹 분리 |
| **SNS / SES** | 뉴스 발송용 메일, 알림 전송 설정 |
| **CloudWatch + Grafana** | 지표 및 로그 모니터링 대시보드 구성 |

---

## 📁 프로젝트 구조

```
terraform-news-project/
├── envs/dev/               # 개발 환경용 메인 Terraform 구성
├── modules/                # 모듈별 리소스 정의
│   ├── eks/                # EKS 클러스터 및 노드 그룹
│   ├── rds/                # RDS 인스턴스
│   ├── lambda/             # Lambda 함수, Layer, 스케줄링
│   ├── networking/         # VPC, Subnet, Route, NAT 등
│   ├── iam/                # IAM 역할 및 정책
│   ├── monitoring/         # CloudWatch + Grafana 대시보드
│   └── sns/                # 알림/이메일 관련 설정
└── .github/workflows/      # GitHub Actions 기반 CI/CD 파이프라인
```

---

## ⚙️ 배포 방법

1. **백엔드 상태 저장소(S3) 설정**

```bash
terraform init -reconfigure -backend-config="..."
```

2. **배포 전 변경 사항 확인**

```bash
terraform plan
```

3. **인프라 배포 실행**

```bash
terraform apply
```

4. **리소스 제거 (필요 시)**

```bash
terraform destroy
```

---

## 🔄 CI/CD 구성 (GitHub Actions)

- PR 생성 시: `terraform plan` 자동 실행 → 변경 사항을 PR에 댓글로 출력
- `main` 브랜치 병합 시: `terraform apply` 자동 실행 → AWS 인프라 반영
- 수동 실행용 워크플로우(`workflow_dispatch`)도 포함

---

## 📌 특징 및 장점

- Lambda 함수와 RDS 보안 그룹을 분리 및 연동
- 모듈 기반 구성으로 재사용성과 유지보수 용이
- Argo Rollouts, Grafana 등 실서비스 수준 구성 반영
