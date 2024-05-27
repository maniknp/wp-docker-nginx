## How to enter into the container

**Using bash:**

```bash
docker exec -it 287c3f7cc9cc /bin/bash`
```
Note: Mostly used for non alpine containers.


**Using ash:**

```ash 
docker exec -it 287c3f7cc9cc /bin/ash`
```
Note: Mostly used for alpine containers.
