-- Tạo database
create database QuanLiBanDacSan;
use QuanLiBanDacSan;

-- Tao bang khach hang
create table KhachHang
( MaKH varchar (10) not null primary key,
  TenKH varchar(30) not null,
  DiaChi varchar (100),
  Sdt varchar(10));

-- Tao bang dac san
create table DacSan
( MaDS varchar(10) not null primary key,
  TenDS varchar(30) not null,
  Loai varchar (40) not null,
  XuatXu varchar(50) not null,
  SLHienCo int,
  MaNCC varchar(10),
  TinhTrang varchar(20),
  Foreign key (MaNCC) references NhaCungCap (MaNCC));

-- Tao bang nha cung cap
create table NhaCungCap
( MaNCC varchar (10) not null primary key,
  TenNCC varchar (50) not null,
  DiaCHi varchar(50) not null,
  Sdt varchar(10),
  Email varchar (50));
  
-- Tao bang nhan vien
create table NhanVien (
MaNV varchar(10) not null primary key,
TenNV varchar(50) not null,
NgaySinh date not null,
GioiTinh char(1) not null,
DiaChi varchar (50),
SDT varchar(10),
ViTri varchar (30) not null,
LuongCoBan numeric not null);

-- Tao bang hoa don nhap
create table HDN (
MaHDN varchar (10) not null primary key,
NgayNhap date not null,
MaNV varchar (10),
MaNCC varchar(10) not null,
Foreign key (MaNV) references NhanVien (MaNV),
Foreign key (MaNCC) references NhaCungCap (MaNCC));

-- Tao bang Hoa don xuat
create table HDX (
MaHDX varchar(10) not null primary key,
NgayXuat date not null,
MaNV varchar (10) not null,
MaKH varchar (10) not null,
Foreign key (MaNV) references NhanVien (MaNV),
Foreign key (MaKH) references KhachHang (MaKH));

-- Tao bang chi tiet HDN
create table ChiTietHDN (
MaHDN varchar (10) not null primary key,
MaDS varchar(10) not null,
SLNhap int not null,
DonGia numeric not null,
Foreign key (MaDS) references DacSan (MaDS));

-- Tao bang chi tiet HDX
create table ChiTietHDX (
MaHDX varchar (10) not null primary key,
MaDS varchar(10) not null,
SLXuat int not null,
DonGia numeric not null,
Foreign key (MaDS) references DacSan (MaDS));

-- Tạo functions
-- 1: Trả về số lượng hoá đơn xuất trong tháng bất kì
-- 2: Trả về số lần được mua của một mặt hàng bất kì
-- 3: Tạo function trả về đặc sản có số lượng mua nhiều nhất

-- Tạo view
-- 1: Tạo view hiển thị những đặc sản chưa được mua lần nào
create view DSduocmua as
select maDS from chitietHDX;

create view DSchuaduocmua as
select maDS,tenDS from dacsan
where maDS not in (select*from DSduocmua);

-- 2: Tạo view hiển thị thông tin những nhân viên chưa nhập hàng lần nào
create view NVchuaNH as
select *from nhanVien 
where maNV not in (select maNV from HDN);
-- 3: Tạo view hiển thị thông tin hoá đơn xuất trong tháng hiện tại được sắp xếp theo ngày

create view ttHDX as
select chitietHDX.MaHDX,MaKH,MaNV,SLXuat,DOngia,NgayXuat from chitietHDX,HDX
where month(NgayXuat)= month(now()) and chitietHDX.MaHDX=HDX.MaHDX 
group by chitietHDX.MaHDX;

-- Tạo procedures
-- 1: Tạo thủ tục để kiểm tra một đặc sản có trong kho của nhà hàng hay không, nếu có hiển thị tên đặc sản, không thì hiện null
delimiter //
create procedure kiemTra (in tenDS varchar(50),out KQ varchar(10))
begin
	set KQ = (select tenDS from dacsan where dacsan.tenDS=tenDS);
end; //
delimiter ;


-- 2: Tạo thủ tục để kiểm tra một nhân viên đã lập bao nhiêu hoá đơn nhập


-- 3: Tạo procedure tính tổng doanh thu bán hàng, trung bình doanh thu của một mặt hàng truyền vào bất kì
delimiter //
create procedure doanhthu (in id int , out total numeric, out average numeric)
begin
	declare count int default 0;
    set count=(select count(id) from chitiethdn 
    where id=msDS);
    if count>0 then
		set total=(select sum(dongia*soluong)
					from chitietHDN where id=mads);
		set average=(select avg(dongia*soluong) 
					from chitiethDN where id=maDS);
		else
			set total=0;
            set average=0;
            select concat('Không có đặc sản này') as 'ERROR';
	end if;
end; //
delimiter ;

-- Tạo trigger
-- 1: Tạo trigger để khi thêm vào bảng chitiethdx thì cập nhật số lượng hiện có trong bảng đặc sản
delimiter //
create trigger chen after insert
on chitiethdx
for each row 
update dacsan
set slhienco= slhienco-new.slxuat
where dacsan.mads=new.maDS; //
delimiter ;
-- 2: Tạo trigger để lưu trữ dữ liệu khách hàng cũ trước khi xoá 
create table LuuTruKH like khachhang;
create trigger LuuTru before delete
on KhachHang
for each row
insert into luuTruKH (MaKH, tenKH,sdt,diachi)
values (old.maKH,old.tenKH,old.sdt,old.diachi);

-- 3: Tạo trigger để đảm bảo trước khi xoá ở bảng
-- cha khách hàng thì xoá ở bảng con hdx
delimiter //
create trigger before_luutru before delete
on khachhang
for each row
begin
	delete from hdx
    where maKH= old.maKH;
end; //
delimiter ;

-- 4: Tạo trigger 