```bash
ab -n 50000 -c 1000 http://wp.localhost/sample-page/
```

```bash
curl -s -o /dev/null -w "
    Time to connect:  %{time_connect}s
    Time to first byte: %{time_starttransfer}s
    Total time:       %{time_total}s
    HTTP Code:        %{http_code}\n" http://wp.localhost/sample-page/
```