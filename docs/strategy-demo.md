# Pipecd Deployment Strategies Demo

## 1. Tổng quan các chiến lược triển khai (Deployment Strategies)

### a. Rolling Update (Simple)
- **Lý thuyết:** Từng Pod cũ được thay thế dần bằng Pod mới, đảm bảo luôn có Pod phục vụ.
- **Demo:** Sử dụng manifest ở `src/deploy/kubernetes/simple/`.
- **Kiểm chứng:** Dùng `kubectl get pods` sẽ thấy Pod mới xuất hiện dần, Pod cũ bị xóa dần.

### b. Canary
- **Lý thuyết:** Deploy một phần nhỏ Pod mới (canary), kiểm tra ổn định rồi mới thay thế toàn bộ.
- **Demo:** Sử dụng manifest ở `src/deploy/kubernetes/canary/`.
- **Kiểm chứng:** Pod canary chạy song song với Pod cũ, traffic được chia cho canary. Sau khi xác nhận, toàn bộ Pod mới sẽ thay thế Pod cũ.

### c. Blue-Green
- **Lý thuyết:** Tạo một môi trường mới (green) song song với môi trường cũ (blue), chuyển traffic sang môi trường mới khi sẵn sàng.
- **Demo:** Tạo thư mục `src/deploy/kubernetes/bluegreen/` với manifest riêng cho blue và green.
- **Kiểm chứng:** Có hai bộ Pod (blue, green), khi chuyển traffic sẽ thấy Pod green nhận traffic thay cho blue.

### d. Manual Approval
- **Lý thuyết:** Quá trình deploy dừng lại ở bước chờ xác nhận thủ công trước khi tiếp tục.
- **Demo:** Tạo thư mục `src/deploy/kubernetes/manual-approval/` với manifest có khai báo approval.
- **Kiểm chứng:** Deploy sẽ dừng ở bước chờ xác nhận, cần thao tác trên giao diện Pipecd để tiếp tục.

### e. Rollback
- **Lý thuyết:** Khi deploy thất bại hoặc có sự cố, hệ thống tự động hoặc thủ công quay về phiên bản trước.
- **Demo:** Sử dụng bất kỳ manifest, sau đó trigger rollback trên Pipecd.
- **Kiểm chứng:** Pod mới bị xóa, Pod cũ được khôi phục.

---

## 2. Cách triển khai demo
- Chuẩn bị manifest cho từng chiến lược ở các thư mục tương ứng.
- Khai báo app trong Pipecd với strategy phù hợp trong file `app.pipecd.yaml`.
- Trigger deploy từ giao diện Pipecd hoặc commit lên repo.
- Dùng `kubectl get pods`, `kubectl get svc`, `kubectl logs` để kiểm tra hiện tượng thực tế.

---

## 3. Danh sách các manifest cần thiết
- `src/deploy/kubernetes/simple/` : Rolling Update
- `src/deploy/kubernetes/canary/` : Canary
- `src/deploy/kubernetes/bluegreen/` : Blue-Green
- `src/deploy/kubernetes/manual-approval/` : Manual Approval

---

## 4. Ghi chú
- Đảm bảo Piped và Control Plane đã kết nối đúng với cluster.
- Có thể bổ sung các chiến lược khác nếu Pipecd hỗ trợ.
- Kiểm tra trạng thái Pod, Service, traffic routing để xác nhận chiến lược hoạt động đúng.
