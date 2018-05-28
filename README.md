# Встроенные плагины в gitsync3

##Плагины для gitsync3

1. `increment` - обеспечивает инкрементальную выгрузку конфигурации в исходники
1. `sync-remote` -  добавляет функциональность синхронизации с удаленным репозиторием git (команды `git pull` и `git push`)
1. `limit` - добавляет возможность ограничения на минимальный, максимальный номер версии хранилища, а так же на лимит на количество выгружаемых версий за один запуск
1. `check-authors` - добавляет функциональность проверки автора версии в хранилище на наличие соответствия в файле `AUTHORS`
1. `check-comments` - добавляет функциональность проверки на заполненность комментариев в хранилище
1. `smart-tags` - добавляет функциональность автоматической расстановки меток в git (команда `git tag`) при изменении версии конфигурации
1. `unpackForm` - добавляет функциональность распаковки обычных форм на исходники
1. `tool1CD` - заменяет использование штатных механизмов 1С на приложение `tool1CD` при синхронизации
1. `disable-support` - снимает конфигурацию с поддержки перед выгрузкой в исходники


## Доработка

Доработка проводится по git-flow. Жду ваших PR.

## Лицензия

Смотри файл [`LICENSE`](./LICENSE).