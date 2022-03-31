extends Node2D

const answers_rating = {
	'bad': 0,
	'normal': 1,
	'good': 2,
}
const answer_tag = '<'
const action_tag = '>'
const variab_tag = ':='
const rating_tag = '#'


export(String, FILE) var dialogue_script
export(NodePath) var dialogue_label_path
export(NodePath) var dialogue_portrait_path
export(NodePath) var choice1
export(NodePath) var choice2
export(NodePath) var choice3
export(NodePath) var choice4

onready var dialogue_label = get_node(dialogue_label_path)
onready var dialogue_portrait = get_node(dialogue_portrait_path)

#const portrait_array1 = [
#	preload("res://resources/portrait_1.tres"),
#	preload("res://resources/portrait_2.tres"),
##	preload("res://resources/portrait_3.tres"),
#]

var portrait_array = [
	Rect2(272, 320, 80, 80),
	Rect2(112, 320, 80, 80),
	Rect2(192, 320, 80, 80),
]

var choices=[]
var data
var dialogue_idx=0
var answer_idx=0

signal player_choice_executed(rate)
signal dialogue_ended

func _ready():
	# init indexes
	choices.append(get_node(choice1))
	choices.append(get_node(choice2))
	choices.append(get_node(choice3))
	choices.append(get_node(choice4))
	data = _parse_dialgue_script()
	play_dialogue()

func set_main_dialogue_text(text):
	var to_replace = data['variables']
	for i in to_replace:
		text = text.replace('$'+i, to_replace[i])
	dialogue_label.text = text

func play_dialogue():
	var dia2play = get_current_dialogue_to_play()
	var actions = dia2play['actions']
	var question = dia2play['question']
	set_main_dialogue_text(question)
	if actions:
		for i in range(choices.size()):
			if i < actions.size():
				set_choice_text(actions[i], i)
			else:
				set_choice_text(null, i)


func play_next_dialogue():
	dialogue_idx+=1
	if get_current_dialogue_to_play():
		play_dialogue()

func display_answer_to_follow(text):
	set_main_dialogue_text(text)
	set_choice_text('.......', 0)
	for i in range(1,3):
		set_choice_text(null, i)

func get_current_answers(n):
	return get_current_dialogue_to_play()['answers'][n] if get_current_dialogue_to_play()['answers'] else null

func play_choice(n):
	if get_current_dialogue_to_play():
		var answers = get_current_answers(n)
		if answers and answer_idx < answers.size():
			var an_text = answers[answer_idx][0]
			var an_rate = answers[answer_idx][1]
			display_answer_to_follow(an_text)
			emit_signal("player_choice_executed", an_rate)
			_change_portrait_on_choice(an_rate)
			answer_idx +=1
		else:
			answer_idx = 0
			play_next_dialogue()
	else:
		end_dialogue()

func _change_portrait_on_choice(rate):
	rate = str(rate).replace('$','')
	var portrait = portrait_array[answers_rating[rate]]
	dialogue_portrait.texture.region = portrait
	dialogue_portrait.update()

func end_dialogue():
	emit_signal("dialogue_ended")

func set_choice_text(text, n):
	if text:
		choices[n].text = text
		choices[n].show()
	else:
		choices[n].hide()

func get_current_dialogue_to_play():
	return data['dialogues'][dialogue_idx] if dialogue_idx < data['dialogues'].size() else null

func _parse_dialgue_script():
	var data = {'variables': {}, 'dialogues': []}
	var temp = {}
	var action_count = 0
	var read_answer = false
	var f = File.new()
	f.open(dialogue_script, File.READ)
	while not f.eof_reached():
		var line = f.get_line().replace('	','')

		if not line:
			continue

		if read_answer:
			_add_answer(temp, line, action_count)
			if _has_finished_answering(line):
				read_answer = false
				action_count+=1

		elif _is_line_action(line):
			read_answer = true
			_add_action(temp, line)
		elif _is_line_variable_definition(line):
			var sp = line.split(variab_tag)
			data['variables'][sp[0]] = sp[1]
		else:
			if temp:
				data['dialogues'].append(temp.duplicate())
				action_count = 0
				temp.clear()
			temp['question'] = line
			temp['answers'] = []
			temp['actions'] = []

	data['dialogues'].append(temp)
	return data

func _is_line_variable_definition(line):
	return line.find(variab_tag) >= 0

func _is_line_action(line):
	return line.begins_with(action_tag)

func _has_finished_answering(line):
	return line.find(answer_tag) >=0


func _add_action(dict, line):
	dict['actions'].append(line.replace(action_tag,''))

func _add_answer(dict, line, count):
	if dict['answers'].size() <= count:
		dict['answers'].append([])

	var test = line.split(rating_tag)
	var rate = ""
	var str_line = ""
	for x in test:
		if x in answers_rating:
			rate = x
		else:
			str_line = x.replace(answer_tag,'')

	dict['answers'][count].append([str_line, rate])

# callbacks
func _on_linkchoice_clicked(n):
	play_choice(n)
