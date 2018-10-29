# Безумные учёные и их невероятные устройства

Проект представляет собой реализацию микросервиса в соответствии с [тестовым заданием](https://docs.google.com/document/d/1ljNmh4MiAHFKaxWOZyoLEtO8A4GF8-8TcejAGrjpiug/edit) на должность начинающего разработчика на Ruby. Микросервис предоставляет REST API для просмотра, добавления, изменения и удаления информации о безумных учёных и их невероятных устройствах.


## Использование

Перед началом использования API необходимо создать базу данных "scientists" (используемая СУБД - PostgreSQL), доступ к которой имеет пользователь с именем "app" и паролем "p@ssw0rd". Имя и пароль пользователя, адрес и порт подключения к серверу базы данных, используемую СУБД, а также название базы данных можно изменить в [соответствующем файле](https://github.com/ExceLLent404/scientists/blob/master/app/db_connection.rb).

Находясь в рабочей папке проекта выполните из консоли следующие команды:
* `bundle install` - установить необходимые библиотеки, используемые в проекте;
* `make init` - создать необходимые таблицы в базе данных;
* `make test` - запустить тесты;
* `make run` - запустить сервис.


## REST API

Доступ к API осуществляется через HTTP по адресу http://localhost:4567. Сервер отправляет и принимает данные в формате JSON


### Получение информации

#### Описание запросов

* `GET /api/scientists` - получение информации обо всех учёных
* `GET /api/scientists/{id}` - получение информации о конкретном учёном
* `GET /api/scientists/{id}/devices` - получение информации обо всех устройствах, изобретённых учёным
* `GET /api/devices` - получение информации обо всех устройствах
* `GET /api/devices/{id}` - получение информации о конкретном устройстве
* `GET /api/devices/{id}/scientists` - получение информации обо всех учёных, которые изобрели данное устройство

#### Формат ответа

Код состояния HTTP:
* `200 OK` в случае наличия записи
* `404 Not Found` в случае отсутствия записи

Заголовок `Content-Type: application/json`

Тело ответа содержит информацию о запрашиваемом ресурсе

### Добавление информации

#### Описание запросов

* `POST /api/scientists` - добавление нового учёного. Тело запроса должно содержать информацию об имени учёного, числовой характеристики его безумности и количестве попыток уничтожить Галактику (поля name, madness и tries).
* `POST /api/devices` - добавление нового устройства. Тело запроса должно содержать информацию о названии устройства и числовой характеристики его разрушительной силы (поля name и power).

Добавление связи Учёный-Устройство (оба запроса добавляют запись о том, что конкретный учёный является изобретателем конкретного устройства):
* `POST /api/scientists/{id}/devices`. Тело запроса должно содержать идентификатор устройства
* `POST /api/devices/{id}/scientists`. Тело запроса должно содержать идентификатор учёного

#### Формат ответа

Код состояния HTTP:
* `201 Created` в случае успешного добавления записи
* `404 Not Found` в случае отсутствия записи об учёном/устройстве, к которому добавляется связь Учёный-Устройство
* `422 Unprocessable Entity` в случае некорректного тела запроса (отсутствие необходимых полей, нарушение ограничений базы данных)

Заголовок `Location` с указанием URL созданного ресурса

### Обновление информации

#### Описание запросов

* `PUT /api/scientists/{id}` - обновление записи об учёном. Тело запроса должно содержать информацию об имени учёного, числовой характеристики его безумности и количестве попыток уничтожить Галактику (поля name, madness и tries).
* `PUT /api/devices/{id}` - обновление записи об устройстве. Тело запроса должно содержать информацию о названии устройства и числовой характеристики его разрушительной силы (поля name и power).

#### Формат ответа

Код состояния HTTP:
* `204 No Content` в случае успешного обновления записи
* `404 Not Found` в случае отсутствия обновляемой записи
* `422 Unprocessable Entity` в случае некорректного тела запроса (отсутствие необходимых полей, нарушение ограничений базы данных)


### Удаление информации

#### Описание запросов

* `DELETE /api/scientists/{id}` - удаление записи об учёном
* `DELETE /api/devices/{id}` - удаление записи об устройстве

Удаление связи Учёный-Устройство (оба запроса удаляют запись о том, что конкретный учёный является изобретателем конкретного устройства):
* `DELETE /api/scientists/{scientist_id}/devices/{device_id}`
* `DELETE /api/devices/{device_id}/scientists/{scientist_id}`


#### Формат ответа

Код состояния HTTP - `204 No Content`


### Примеры запросов

#### Получение информации обо всех учёных
```
GET /api/scientists
```
```
Status: 200 OK
Content-Type: application/json

{
  "scientists": [
    {
      "id": 1,
      "name": "James Watt",
      "madness": 50,
      "tries": 1,
      "timestamp": "2018-10-24 13:25:46 +0300"
    },
    {
      "id": 2,
      "name": "Thomas Edison",
      "madness": 73,
      "tries": 4,
      "timestamp": "2018-10-24 13:25:46 +0300"
    }
  ]
}
```
---

#### Добавление нового устройства
```
POST /api/devices

{
  "name": "Steam engine",
  "power": 90
}
```
```
Status: 201 Created
Location: /api/devices/2
```
---

#### Добавление связи Учёный-Устройство
```
POST /api/scientists/1/devices

{
  "id": 2
}
```
```
Status: 201 Created
```
---

#### Обновление записи об учёном
```
PUT /api/scientists/2

{
  "name": "Thomas Edison",
  "madness": 75,
  "tries": 5
}
```
```
Status: 204 No Content
```
---

#### Удаление записи об устройстве
```
DELETE /api/devices/2
```
```
Status: 204 No Content
```
