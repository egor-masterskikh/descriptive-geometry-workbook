project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

readarray -d : -t font_dirs_arr <<<"$OSFONTDIR"

project_fonts_are_loaded=false

for font_dir in "${font_dirs_arr[@]}"; do
  if [ "$font_dir" == "$project_dir/fonts" ]; then
    project_fonts_are_loaded=true
    break
  fi
done

if ! $project_fonts_are_loaded; then
  OSFONTDIR+=":$project_dir/fonts"
  export OSFONTDIR
fi

# при первом запуске необходимо обновить базу данных шрифтов
# для этого раскомментируйте следующие две строчки
#  mtxrun --generate
#  mtxrun --script font --reload
# после первого запуска их можно закомментировать

# TODO: скомпилировать все .asy файлы
# TODO: добавить аргументы скрипта

context main.mkiv --luatex --result="Рабочая_тетрадь_по_начерту"
