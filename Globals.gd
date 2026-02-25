extends Node

#use this class to store variables the whole game needs:
#access any variable from here by doing Global.variable_name

var parameters = {
	"plant_cap" : 150,
	"temperature" : 75
}

var golgi_text = "The Golgi apparatus (or complex/body) is a membrane-bound organelle in eukaryotic cells, composed of stacks of flattened sacs called cisternae. It functions as the cell's 'post office' or shipping center, modifying, sorting, and packaging proteins and lipids synthesized in the endoplasmic reticulum for secretion or delivery to other organelles."

var nucleus_text = "The nucleus and endoplasmic reticulum (ER) are physically and functionally interconnected organelles, with the outer nuclear membrane being directly continuous with the ER membrane. This structural link allows the ER lumen to be continuous with the perinuclear space, facilitating the direct export of synthesized mRNA and proteins from the nucleus to the rough ER for processing"

var smooth_er_text = "Smooth endoplasmic reticulum (smooth ER or SER) is a network of tubular, membrane-bound sacs lacking ribosomes, primarily responsible for lipid synthesis, steroid hormone production, detoxification (e.g., in the liver), and calcium ion storage in muscle cells."

var vacuole_text = "A vacuole is a membrane-bound, fluid-filled organelle found in plant, fungal, and some animal/protist cells that functions primarily in storage, waste disposal, and maintaining structural integrity. "

var mito_text = "Mitochondria are specialized, double-membraned organelles, known as the powerhouse of the cell, that generate over 90% of cellular energy as ATP through oxidative phosphorylation. Beyond energy production, they play vital roles in metabolic regulation, signaling, and initiating apoptosis."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
