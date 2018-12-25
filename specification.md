# Спецификации

### moonwatchd
- Следит за изменениями файлов, указанных в /etc/sysmoon/watch.list
- Изменения посылаются в очередь

### moondatad
- Заносит изменения в базу данных
- Производит реплику каждые (N) минут (читает из конфига)

### moonapply
- применяет изменения из файла архива (реплики БД)
- можно установить игнорирование тех или иных ошибок в конфиге


## Конфиги
- /etc/sysmoon/watch.list
  - /etc
  - /etc/file
  - ^/etc/sysmoon

- /etc/sysmoon/apply-rules.conf
  - conflicts:
	- no package available: ignore|warn|notify|error
	- file merge conflict ...
	- package ver differ ...
	- whole system differ ...
  - services:
	- restart if package contains service: y\n

### moonwatchd
- read_config
- subscribe_events
  - get_watched_files
  - add_files_to_watcher
- start_loop

### moondatad
- read_config
- subscribe_events
- db_connect
- start_loop

#### on event got:
- db_write
