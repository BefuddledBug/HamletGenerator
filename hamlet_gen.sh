#!/bin/bash
# hamlet_gen.sh v1.0
# This project is licensed under the MIT License.
# Feel free to download, use and hack this software!

if command -v figlet > /dev/null; then
    figlet "HamletGen.sh"
else
    echo "== HamletGen =="
fi
echo "hamlet_gen.sh v1.0"
read -p "Enter the number of columns (x, max 10): " x
read -p "Enter the number of rows (y, max 10): " y

if ! [[ "$x" =~ ^[0-9]+$ ]] || ! [[ "$y" =~ ^[0-9]+$ ]]; then
  echo "Error: please enter positive integer numbers only."
  exit 1
fi

if (( x > 10 || y > 10 )); then
  echo "Error: both x and y must be at most 10."
  exit 1
fi

area=$((x * y))

if (( area < 30 )); then
  min_imp=3
  max_imp=5
else
  min_imp=5
  max_imp=10
fi

echo "For the selected size, you can choose between $min_imp and $max_imp points of interest."
read -p "How many points of interest do you want? " imp

if ! [[ "$imp" =~ ^[0-9]+$ ]] || (( imp < min_imp || imp > max_imp )); then
  echo "Error: please enter an integer between $min_imp and $max_imp."
  exit 1
fi

total_cells=$((x * y))
if (( imp > total_cells )); then
  echo "Error: the number of important places cannot exceed the total number of cells ($total_cells)."
  exit 1
fi

# List of places and their corresponding symbols
places=(
  "Tavern" "[$]"
  "Cemetery" "[C]"
  "Temple/Church" "[T]"
  "Village leader's house" "[V]"
  "Blacksmith" "[F]"
  "Market" "[M]"
  "Square" "[P]"
  "Stable" "[S]"
  "Carpenter" "[L]"
  "Hermit's hut" "[E]"
  "Alchemist" "[A]"
  "Library" "[B]"
  "Wizard's tower" "[G]"
  "Barracks" "[R]"
  "Fountain or public well" "[O]"
  "Inn" "[N]"
  "School" "[U]"
  "Circus" "[I]"
  "Prison" "[J]"
  "Healer's house" "[H]"
)

# Settlement types for description
settlements=("Village" "Hamlet" "Settlement" "Community" "Township" "Burgh")

# Peculiarities list
peculiarities=(
  "There's a secret guild of thieves operating in the shadows."
  "Wolves roam the streets after sundown."
  "Wandering merchants avoid the village these days."
  "The well water tastes strangely bitter."
  "A mysterious fog settles every evening."
  "The local blacksmith is rumored to be a retired assassin."
  "Children speak of a ghost that haunts the old mill."
  "An ancient stone circle lies hidden in the nearby woods."
  "The village elder never leaves his house after sunset."
  "Strange runes appear overnight on the walls of the temple."
  "A traveling bard tells tales of a lost treasure nearby."
  "The crops have been failing for three seasons straight."
  "A sacred animal is said to protect the village."
  "A band of mercenaries has been seen camped outside the borders."
  "The town’s clocks stopped working a week ago."
  "Unexplained lights flicker in the abandoned watchtower."
  "The river that supplies the village has turned a strange color."
  "The cemetery is rumored to be cursed."
  "An eerie silence falls whenever the church bell tolls."
  "The local healer practices strange herbal rituals at midnight."
  "Livestock have been disappearing without a trace."
  "A reclusive wizard lives in the outskirts and never welcomes visitors."
  "The marketplace is always empty before noon."
  "A sacred relic was stolen from the temple last moon."
  "Travelers speak of a phantom carriage that rides through the village."
  "The village dogs refuse to enter the forest."
  "An ancient prophecy is said to foretell doom for the village."
  "The tavern is known for a secret back room where deals are made."
  "The main road is guarded by a silent knight in shining armor."
  "A wildflower unique to the area grows only near the village wells."
  "Strange symbols are carved into the trees surrounding the settlement."
  "A belligerent ghost haunts the old bridge after dark."
  "Villagers whisper of a hidden underground tunnel network."
  "The local school teaches forbidden knowledge."
  "The village square hosts a market only under the full moon."
)

# Randomly select places to use
declare -a chosen_places=()
declare -a chosen_symbols=()

indices=($(shuf -i 0-19 -n $imp))

for idx in "${indices[@]}"; do
  chosen_places+=("${places[$((idx*2))]}")
  chosen_symbols+=("${places[$((idx*2+1))]}")
done

declare -A important_positions_symbols
positions_set=()

while (( ${#positions_set[@]} < imp )); do
  rand=$((RANDOM % total_cells))
  if [[ -z "${positions_set[$rand]}" ]]; then
    positions_set[$rand]=1
  fi
done

symbols_copy=("${chosen_symbols[@]}")
random_order=($(shuf -e "${!positions_set[@]}"))
for ((i=0; i<imp; i++)); do
  important_positions_symbols[${random_order[i]}]=${symbols_copy[i]}
done

if (( x <= 5 )); then
  side_cols=2
elif (( x <= 8 )); then
  side_cols=3
else
  side_cols=4
fi

mid=$((y / 2))

get_column_heights() {
  local side_cols=$1
  local -n heights=$2
  heights=()
  if (( side_cols == 2 )); then
    heights=(1 3)
  elif (( side_cols == 3 )); then
    heights=(1 2 3)
  elif (( side_cols == 4 )); then
    heights=(1 3 5 3)
  fi
}

generate_col_heights() {
  local n=$1
  local -n out=$2
  out=()
  for ((i = 0; i < n; i++)); do
    offset=$((-(n / 2) + i))
    out+=($((mid + offset)))
  done
}

declare -a col_heights
get_column_heights $side_cols col_heights

declare -a left_columns=()
for ((i = 0; i < side_cols; i++)); do
  generate_col_heights ${col_heights[i]} col
  left_columns+=("$(IFS=,; echo "${col[*]}")")
done

right_columns=()
for ((idx=${#left_columns[@]}-1; idx>=0; idx--)); do
  right_columns+=("${left_columns[$idx]}")
done

print_extra_column() {
  local row=$1
  local encoded=$2
  IFS=',' read -ra positions <<< "$encoded"
  for pos in "${positions[@]}"; do
    if [[ $row -eq $pos ]]; then
      echo -n "[ ] "
      return
    fi
  done
  echo -n "    "
}

# --- Generate descriptive phrase ---
population=$(( x * y * 4 ))
settlement=${settlements[RANDOM % ${#settlements[@]}]}
phrases=(
  "A tiny %s with just a handful of souls."
  "A quaint %s of around %d residents."
  "A close-knit %s home to nearly %d people."
  "A small %s bustling with about %d souls."
  "A thriving %s of roughly %d inhabitants."
  "A growing %s housing some %d residents."
  "An expansive %s where %d souls live and work."
  "A lively %s with a population close to %d."
  "A prosperous %s with around %d citizens."
  "A large %s sheltering about %d inhabitants."
)
phrase_template=${phrases[RANDOM % ${#phrases[@]}]}
if [[ $phrase_template == *"%d"* ]]; then
  printf "$phrase_template\n\n" "$settlement" "$population"
else
  printf "$phrase_template\n\n" "$settlement"
fi

counter=0
for ((i = 0; i < y; i++)); do
  for col in "${left_columns[@]}"; do
    print_extra_column $i "$col"
  done

  for ((j = 0; j < x; j++)); do
    if [[ -n "${important_positions_symbols[$counter]}" ]]; then
      echo -n "${important_positions_symbols[$counter]} "
    else
      echo -n "[ ] "
    fi
    ((counter++))
  done

  for col in "${right_columns[@]}"; do
    print_extra_column $i "$col"
  done

  echo
done

echo
echo "Legend:"
for ((i=0; i<imp; i++)); do
  echo "${chosen_symbols[i]} = ${chosen_places[i]}"
done

# --- Print peculiarities ---
if (( area <= 30 )); then
  pec_count=1
else
  pec_count=2
fi

echo
echo "Peculiarities:"
pec_indices=($(shuf -i 0-$((${#peculiarities[@]} - 1)) -n $pec_count))

for idx in "${pec_indices[@]}"; do
  echo "- ${peculiarities[$idx]}"
done
