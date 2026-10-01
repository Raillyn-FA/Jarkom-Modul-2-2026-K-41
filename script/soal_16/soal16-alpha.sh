#!/bin/bash

apt-get update && apt-get install -y apache2-utils

echo "=== MEMULAI BENCHMARK WWW ==="
ab -n 250 -c 10 http://www.k41.com/

echo "=== MEMULAI BENCHMARK STATIC ==="
ab -n 250 -c 10 http://static.k41.com/

echo "=== BENCHMARK SELESAI ==="
