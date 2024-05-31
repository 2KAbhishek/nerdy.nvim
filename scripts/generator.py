import requests

target = open("./lua/nerdy/icons.lua", "w")
lua_str = "-- Generated with `python scripts/generator.py`\nreturn {\n"
target.write(lua_str)

nerd_font_src = "ryanoasis/nerd-fonts/master"
url = "https://raw.githubusercontent.com/" + nerd_font_src + "/glyphnames.json"
response = requests.get(url)
data = response.json()

indent = "    "
for i in data:
    if i != "METADATA":
        code = str(data[i]["code"])
        char = str(data[i]["char"])
        target.write(f'{indent}["{i} ({code})"] = "{char}",\n')

target.write("}")
target.close()
