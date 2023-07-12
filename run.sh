set -e  # exit immediately if a command exits with a non-zero status.

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

if [ "$1" == "--setup" ]; then
  mtxrun --generate
  mtxrun --script font --reload
fi

# compile all .asy files
find ./ -mindepth 2 -type f -regex '.*/figures/[A-Za-zА-Яа-я0-9_\-]+\.asy' -execdir asy -verbose '{}' +

context main.mkiv --luatex --result="Рабочая_тетрадь_по_начерту"
