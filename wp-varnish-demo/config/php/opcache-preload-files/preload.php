<?php 
// function to cehck if file exists then compiling
function compile_file_if_exists_by_mani($file) {
    if (is_file($file)) {
        opcache_compile_file($file);
    }
}

// function check is directory exists then compiling all files
function compile_dir_if_exists_by_mani($dir) {
    if (is_dir($dir)) {
        $dir = rtrim($dir, '/');
        $files = glob($dir . '/*.php');
        foreach ($files as $file) {
            compile_file_if_exists_by_mani($file);
        }
    }
}


// recursive function to compile all files in a directory and its subdirectories
function compile_dir_recursive_if_exists_by_mani($dir) {
    if (is_dir($dir)) {
        $dir = rtrim($dir, '/');
        $files = glob($dir . '/*');
        foreach ($files as $file) {
            if (is_file($file)) {
                compile_file_if_exists_by_mani($file);
            } elseif (is_dir($file)) {
                compile_dir_recursive_if_exists_by_mani($file);
            }
        }
    }
}



$wordpress_root = '/var/www/public';
compile_file_if_exists_by_mani("{$wordpress_root}/wp-config.php");
compile_file_if_exists_by_mani("{$wordpress_root}/wp-login.php");
compile_file_if_exists_by_mani("{$wordpress_root}/wp-signup.php");
compile_file_if_exists_by_mani("{$wordpress_root}/wp-mail.php");
compile_file_if_exists_by_mani("{$wordpress_root}/wp-activate.php");
compile_file_if_exists_by_mani("{$wordpress_root}/wp-blog-header.php");
compile_file_if_exists_by_mani("{$wordpress_root}/wp-comments-post.php");
compile_file_if_exists_by_mani("{$wordpress_root}/wp-cron.php");
compile_file_if_exists_by_mani("{$wordpress_root}/wp-links-opml.php");
compile_file_if_exists_by_mani("{$wordpress_root}/wp-settings.php");
compile_file_if_exists_by_mani("{$wordpress_root}/wp-trackback.php");
compile_file_if_exists_by_mani("{$wordpress_root}/xmlrpc.php");

// ====  Compile all files of follwoing directories ====
// compile_dir_if_exists_by_mani('/var/www/html/wp-includes');
compile_dir_recursive_if_exists_by_mani("{$wordpress_root}/wp-includes");