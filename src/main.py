from ai_decorators import AiTools
from api_key import API_KEY

ai_tool = AiTools(API_KEY)

@ai_tool.ai_function([("question", "str")], "str")
def answer_question_drunk(question):
    """
    Returns a answer to the question as a drunk person would.
    """

@ai_tool.ai_function([("question", "str"), ("hint_count", "int")], "list[str]")
def get_hints(question, hint_count):
    """
    Returns [hint_count] hints for how to figure out an answer to the [question].
    The Hints are helpful to find an answer on there own but do not give an imediat answer.
    """

@ai_tool.ai_function([("array_string", "str")], "str")
def format_array_string(array_string):
    """
    Formats the array string to a list of strings.
    i.e. ['test1', 'test2', 'test3'] ->
    1. test1
    2. test2
    3. test3
    """

def drunk_ineraction():
    question = input("Enter a question:\n")
    print("\n\n")
    print("Answer:\n" + str(answer_question_drunk(question)))
    print("\n\n")

def hint_ineraction():
    question = input("Enter a question:\n")
    print("\n\n")
    hint_count = int(input("Enter how many hints you want:\n"))
    print("\n\n")
    print("Hints:\n" + str(format_array_string(str(get_hints(question, hint_count)))))
    print("\n\n")

def main():
    # drunk_ineraction()
    hint_ineraction()

main()
