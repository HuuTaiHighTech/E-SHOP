<?php
$host = 'localhost';
$db   = 'test-etech'; // Đảm bảo rằng tên cơ sở dữ liệu là chính xác.
$user = 'root';
$pass = ''; // Mật khẩu cho người dùng root, nếu có.
$charset = 'utf8mb4';

$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
try {
    $pdo = new PDO($dsn, $user, $pass, $options);
} catch (\PDOException $e) {
    throw new \PDOException($e->getMessage(), (int)$e->getCode());
}

require_once 'vendor/autoload.php'; // Đảm bảo rằng đường dẫn này chính xác.
$faker = Faker\Factory::create();

// Bắt đầu một giao dịch
$pdo->beginTransaction();

// Chuẩn bị câu lệnh SQL
$sql = "INSERT INTO products (title, slug, summary, description, photo, stock, size, `condition`, status, price, discount, is_featured, cat_id, child_cat_id, brand_id, created_at, updated_at)
        VALUES (:title, :slug, :summary, :description, :photo, :stock, :size, :condition, :status, :price, :discount, :is_featured, :cat_id, :child_cat_id, :brand_id, NOW(), NOW())";

$stmt = $pdo->prepare($sql);

for ($i = 0; $i < 500; $i++) {
    // Tạo dữ liệu ngẫu nhiên cho mỗi sản phẩm
    $title = $faker->sentence(3);
    $slug = strtolower(trim(preg_replace('/[^A-Za-z0-9-]+/', '-', $title), '-'));
    $summary = $faker->text(200);
    $description = $faker->text(1000);
    // Giả sử bạn muốn lưu trữ tên file ảnh thay vì đường dẫn đầy đủ
    $photo = $faker->image('/path/to/directory', 640, 480, 'fashion', false);
    $stock = $faker->randomDigitNotNull;
    $size = $faker->randomElement(['S', 'M', 'L', 'XL', 'XXL']);
    $condition = $faker->randomElement(['new', 'hot', 'default']);
    $status = 'active';
    $price = $faker->randomFloat(2, 10, 5000);
    $discount = $faker->numberBetween(0, 100);
    $is_featured = $faker->boolean ? 1 : 0;
    $cat_id = $faker->numberBetween(1, 10);
    $child_cat_id = $faker->numberBetween(1, 10); // Đảm bảo cột này chấp nhận giá trị không phải NULL
    $brand_id = $faker->numberBetween(1, 5);

    // Ràng buộc dữ liệu với các tham số
    $stmt->execute([
        ':title' => $title,
        ':slug' => $slug,
        ':summary' => $summary,
        ':description' => $description,
        ':photo' => $photo,
        ':stock' => $stock,
        ':size' => $size,
        ':condition' => $condition,
        ':status' => $status,
        ':price' => $price,
        ':discount' => $discount,
        ':is_featured' => $is_featured,
        ':cat_id' => $cat_id,
        ':child_cat_id' => $child_cat_id,
        ':brand_id' => $brand_id
    ]);
}

// Hoàn tất giao dịch
$pdo->commit();
echo "Đã chèn 500 sản phẩm.";
?>
