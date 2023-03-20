"""
Applet: The Tracker
Summary: Show social & ecom numbers
Description: Flexible counter to display any of your data supported by a tolta.co tracker. Stats from Twitter, YouTube, Ghost, ChartMogul, Paddle, Instagram (coming), and more!
Author: Steve Rybka
"""

load("cache.star", "cache")
load("html.star", "html")
load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("encoding/base64.star", "base64")

CACHE_KEY = "data"
CACHE_TTL = 600
DEFAULT_CODE = "2063b7a15415799b999f1b7382d4a139"
DEFAULT_COLOR = "#1DA1F2"
DEFAULT_LAYOUT = "Top"
DEFAULT_FONT = "tb-8"
DEFAULT_BANNER = "Followers"
DEFAULT_FORMAT = "Full"
DEFAULT_ICON = """iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAACXBIWXMAAAsTAAALEwEAmpwYAAABSElEQVR4nI2QO0vDYBSGv9C5mw7dFEsHQU3tRWrbpBdDQ23TSC8Kbv4DFwdxEl0cHISqi4gg+AMcGsFF/CdCG9Om+dKvtUo7vJLVtOoDB1447zOcQ8gEOsqe1xnyH1CtelhhW2OFWsPJ5C9YrnLE5AqYXIadKx/+WqZSibclddSTtmBvqKBZZUTFEj9VsDPKM00roOkiaKoIKhZgifmniWUrmRcsYROWkMfwJICP4wC6cRnd9RysNTnhEsy4fOUs7d0oxq8cxi8caC0MM5JFO5Spu4RONKN1IlkMb734ahB8PhIM6l60eQHtFUFzCQYvXpupCAYPBP17gv4dAbshMGKr0Bdjly5BX07OG/HggF4QWOcE3TMO5ikHPbQ0NBaC/omHt/xh8X1nlhkHHPR9Dk11ptea48Wpb3UAqXreEj61mfSVnPyz8A0s+58mcDA2swAAAABJRU5ErkJggg=="""

def render_error():
    return render.Root(
        render.WrappedText("Something went wrong!"),
    )

def main(config):
    # Load user settings from Tidbyt app, or grab defaults
    layout = config.str("layout", DEFAULT_LAYOUT)
    color = config.str("color", DEFAULT_COLOR)
    code = config.str("code", DEFAULT_CODE)
    banner = config.str("banner", DEFAULT_BANNER)
    font = config.str("font", DEFAULT_FONT)
    format = config.str("format", DEFAULT_FORMAT)
    icon = base64.decode(config.get("icon", DEFAULT_ICON))

    # Get tolta.co page with user's ID
    TOLTA_URL = "https://embed.tolta.co/" + code
    response = http.get(TOLTA_URL)
    html_data = html(response.body())

    # Print the full HTML content
    print(html_data)

    # Extract the body content
    body_content = html_data.find("body").first().text().strip()

    # Print the body content
    print(body_content)

    # Body content with no comma
    body_content_nocomma = body_content.replace(",", "")

    # Body content with no dollar sign
    body_content_nodollar = body_content.replace("$", "")

    # Body content with no comma and dollar sign
    body_content_nosigns = body_content.replace(",", "").replace("$", "")

    # Get final content based on user selections
    if format == "Full":
        final_content = body_content
    if format == "Comma":
        final_content = body_content_nocomma
    if format == "Dollar":
        final_content = body_content_nodollar
    if format == "Signs":
        final_content = body_content_nosigns

    print(final_content)

    # If user has entered a bad or empty tracking id
    if len(code) == 0:
        final_content = "no ID"
    if body_content == "No counter":
        final_content = "bad ID"

    print(final_content)

    # Top & bottom layout
    if layout == "Top":
        return render.Root(
            child = render.Column(
                expanded=True,
                main_align="space_evenly",
                cross_align="center",
                children = [
                    render.Text(
                        content = banner,
                        font = font,
                    ),
                    render.Box(
                        width = 64,
                        height = 1,
                        color = color),
                    render.Text(
                        content = final_content,
                        font = font,
                    ),
                ],
            ),
        )

    # Side by side layout
    if layout == "Side":
        return render.Root(
            child = render.Box(
                render.Row(
                    expanded=True,
                    main_align="space_evenly",
                    cross_align="center",
                    children = [
                        render.Image(src=icon),
                        render.Text(
                            content = final_content,
                            color = "#fff",
                            font = font,
                        ),
                    ],
                ),
            ),
        )

    # Number only layout
    if layout == "Number":
        return render.Root(
            child = render.Box(
                render.Row(
                    expanded=True,
                    main_align="space_evenly",
                    cross_align="center",
                    children = [
                        render.Text(
                            content = final_content,
                            font = font,
                        ),
                    ],
                ),
            ),
        )

def get_schema():
    colors = [
        schema.Option(display = "Ghost White", value = "#FFFFFF"),
        schema.Option(display = "Twitter Blue", value = "#1DA1F2"),
        schema.Option(display = "Instagram Purple", value = "#833AB4"),
        schema.Option(display = "YouTube Red", value = "#FF0000"),
        schema.Option(display = "Gumroad Pink", value = "#FF90E8"),
        schema.Option(display = "Paddle Yellow", value = "#FFE450"),
        schema.Option(display = "Money Green", value = "#2E7E74"),
        schema.Option(display = "Slime Orange", value = "#FE4D00"),
    ]
    icons = [
        schema.Option(display = "Twitter Bird", value = """iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAABLUlEQVR4nK1SPUsDQRBdd3JaWSkWdlYWdiL4MyzE3k7xB9gKNlqk0FIQLMTL2xM/Ku38ARFJZy9iIQEh9+ZQJLhyBpJcvFwSyMCwMLPv7XuzY8xYwvuJQVeCkEtSSdZM1FhsF0988Hdax6pFvJOLjPykQCFOfTuh5wLui9NnYy7i2VaRTRvpZi/eQvcy4K604L0JoMs9jbK5rU93CFjLJQCbKdaUwmQ150JdwMPUszi+9SF4bT1xxTkBf/rJLJBf6/h0rI5OoJdtAkG8PjKBS7Yz0xanlaEJoDTXjZl//20db4Yj4EH+ukVe0maxdD6ZOz+VXVFwwyLZEvBUnH4UTj5M5rPewbPBsvkt0OPuBctEKUxWBHpkHR8F+i7gl4Av1umDhe6a6HMh3/MY4hcwAZqpRCof8AAAAABJRU5ErkJggg=="""),
        schema.Option(display = "Instagram Camera 16px", value = """iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA4dpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDkuMC1jMDAxIDc5LjE0ZWNiNDJmMmMsIDIwMjMvMDEvMTMtMTI6MjU6NDQgICAgICAgICI+IDxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+IDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVmIyIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6YTcyYmVhZjYtMjI0Zi00NTYzLTliNjEtMTBhODkxNDJmZTMzIiB4bXBNTTpEb2N1bWVudElEPSJ4bXAuZGlkOjE5QUM2N0U5QkUyMTExRUQ5NzVDREMwQUE3MjM2QTBEIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjE5QUM2N0U4QkUyMTExRUQ5NzVDREMwQUE3MjM2QTBEIiB4bXA6Q3JlYXRvclRvb2w9IkFkb2JlIFBob3Rvc2hvcCAyNC4yIChNYWNpbnRvc2gpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6YmQ3NzU4YWUtODZhMS00MjgyLTg0MjctNDg3ZDM3MDM0NzUyIiBzdFJlZjpkb2N1bWVudElEPSJhZG9iZTpkb2NpZDpwaG90b3Nob3A6Y2VjZWYwNTEtZTJkYi05NjQxLWJjYzYtMGIwNjRjZTIyMjhhIi8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+IK4mlwAAA0xJREFUeNqEU21oFEcYfmdnb293b+8j9xFzUdMGYkgaTqRSSUEMUYxSPUKkJBIlSmghRf0hAUXS1h/h1DYGRUTxoyTU2jTWfyH+0CtpiCRGiR6JgmiN0ETTHveRy+V2dje3u927ZC34x4Fnhpd53mee950ZBMZgEE23C8ETjez2b5xQ7BdVK+RAVBaIZiAfsyCpHMT1eHQM+q8NQnenAkRGHFiYHm/zz018bdMzORmNyNGnokZnZc0CigFZY1bWXGxFHr3yk2I9sPoB/D7QA4f3QmhVzbd6+Xn9N++Bm4XY4YEPDBcUulug+2ovZPQG6AhBsqYtFlt/9J8CirW9T3YiweFCDpcZH2NCfV1M34QTPM5ONPKqC54mKdda5JliX08lNSljEqssxZW/uI/cHvWdmxlyX37zk/1MeANdVa1AOmVFGiawSObQkydu5HHR4FkE1UE0MzlgKaq4W3RouAj5fYOZvx4saEjaYv1s20b6xy1t6ZN1F7I/tGmgA0tlKQ4IUOAxDrZL72yfWVNzuojlfK3xKy2746c+b06GalsXvq9lMFHbbQcvUoBxjmelssBhaUXAIS83iGHsWz/21j3Gkw97MuM3TNERZfLPO0q4fyOztqoE+8vyV08t5QVoKBDfOcAUomifiGUxLb3fUBWJRMAK0AjRywIKcJRsOHARAGHZQUKWU+NLM6PVFd7NX/hKtv3fl+KKZmFD46z2enZWjU4vP74l4PMOcgK8kifqOkDHRKTjj4bC4cGddeFbUzM3yTwmX6JNTTadsx9P9h4WdYnkuJaVEihwGpOgIPO04b9jY8GB8M4p9e1EY6B034HKqq9iXPzf1tj1/b+K430mz2gishkloYVH/gRJ0aQs+KYsTTRiErAhWe5yrsMaxq8WU9NEVRVzjwEa3y8MveTB7cUeny5s38PuKuEt/qFH8pCk6HmiUQ3EJDkRlUksq+uqmexALH/WXd9dz3+643rm3kUk2BB3+5Kjf0fQHpx7iGYiES2STTNZEBmAjIE0C7BoNVYr0GkOB+SPAmuU8tK788/DjbHePfnabTxiO9tt3x2st39dwPE+SBlJKQ5g3kCCN2B8k3gOAizMosSNF9M9HXNDJ1OanPlPgAEAcPheP0TTVRgAAAAASUVORK5CYII="""),
        schema.Option(display = "Instagram Camera 12px", value = """iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA4dpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDkuMC1jMDAxIDc5LjE0ZWNiNDJmMmMsIDIwMjMvMDEvMTMtMTI6MjU6NDQgICAgICAgICI+IDxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+IDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVmIyIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6YTcyYmVhZjYtMjI0Zi00NTYzLTliNjEtMTBhODkxNDJmZTMzIiB4bXBNTTpEb2N1bWVudElEPSJ4bXAuZGlkOkZFNDk0MkVBQkUyNTExRUQ5NzVDREMwQUE3MjM2QTBEIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOkZFNDk0MkU5QkUyNTExRUQ5NzVDREMwQUE3MjM2QTBEIiB4bXA6Q3JlYXRvclRvb2w9IkFkb2JlIFBob3Rvc2hvcCAyNC4yIChNYWNpbnRvc2gpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6YmQ3NzU4YWUtODZhMS00MjgyLTg0MjctNDg3ZDM3MDM0NzUyIiBzdFJlZjpkb2N1bWVudElEPSJhZG9iZTpkb2NpZDpwaG90b3Nob3A6Y2VjZWYwNTEtZTJkYi05NjQxLWJjYzYtMGIwNjRjZTIyMjhhIi8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+4UvrugAAAitJREFUeNpMj29IE3EYx5/f73e73e5u625uOx29iAr1pZGDGhS2AosIqhdhCNH6o5aCC0KFCBsVlcV0kTQoCiQISqMXUVRIar0S31gwiUoIIsnK7dxuc/Puft1Jgl94eB6e5/k+fB4ElqLCjlM9YvMN1qzyqjoHeZ2HvMGvZE13w4Kpqc/h+oVxeDjItHlCJwfkQ6k76vu7o8UvY2WKjZKJDJ1ioJQlJUqXN8D28BG4fBuAmqiwLZZ79P3rUMvci3b4LwIIMMJkmRrGLrKv2YuUoKFXSjshGsOuzWXxFU2/thc5cDhvSU3JtJLKTHqHsnEhdl/B/qATOfjP6N0bGbt4BqoygDgd24aEv/HmcVeotePv407VMAtdfEvCCR/f9mh9R7fgcKPA5C2qxH56sKbyAGMhlMKxQodc37aK1sDW7U37nlIZuyvqyNbIS9eU9ZmyCNSpW9QIkfWLROM1bdVQRgXNzRSAAUwIMkBkNKsO5IFwhv2gPqzOPOlvqE9mR0vZYg4Vk1JT6lN5evyPqc5XE+QQV8wBDUyHbtoXz0xMtT/YzXAjkcgI+iHhidmfY60Lw8eoNcPIMNcxSwBL00FtsLtiANbI5+RkhRX8a3u9nsPXvin3iiRX0jMXz4lxmXW4Wcqwm/yujQGRDQQEVqkV5epazldzWgxFz7v3dMfVZ13IdsdOuM5e6ZSvCqYgwbwA8FsE+OUBmLNDguIsn7s0M9nbl/3Q/0+AAQDcFNKFzUh1WgAAAABJRU5ErkJggg=="""),
        schema.Option(display = "YouTube Play Button", value = """iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAoUlEQVQ4T7WTQQ5AMBBFO+7BEbB0/xU7egPtIexU/6SNlIohWNAw/3X++CUVLleVLq4lTzKWUMc3Flsr0SU15BTRWzFIAzr4FrAKx1Cw80MHOTEKr6D+225hNvkBhp1yEK21WtomzOAOAPyhk2eAjA054GIGKQAhkv4B7wbi2vs/5UCPkyiNEP8UJNH+exFb4MNEShjBVNzhMMVX/UMIxNBuxtFrcajgs70AAAAASUVORK5CYII="""),
        schema.Option(display = "YouTube Play Button2", value = """iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAtElEQVR4nGNgGB7gPwMD438bhrz/Ngwb/9synP9vy/D0vy3Du/82DH/AGMS2ZXjy34bhHFiNDUMuSA/CAFsG//+2DP9JxP7IBjRiKPAR+f/fgQW3ATYMTcgGzMJQUBf6///DG///l3riMmQewgAbhqVYDYCBo5v//w9XQjdgNaUGLKPMCzYM/ZQGYjll0WjN4IuakGwZcqAJ6cx/G4ZH0IT0G4wh7Ef/bRjOQtVkUzUlDywAAIk7NiMMlzl3AAAAAElFTkSuQmCC"""),
        schema.Option(display = "YouTube Play Button3", value = """iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAl0lEQVR4nGNgoAZ4amzM9dBGV5AUDNID1nzHVK/vjqnev7umev9JwSA9d0x0exjumur9JFUzEv7BgE3inqXR/0fBvkQZwoBN8Elc5P9/f/78/7hy2f/7TjZkGBAf+R8G/n788P9Nb+f/u+YG5BkAAz+uXfn/KNR/AAz4S5YX4igMxHskRuNPihISKDmSnZRNdbspz0yUAgAiiviMp3rCiwAAAABJRU5ErkJggg=="""),


        schema.Option(display = "Fire", value = """iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAACXBIWXMAAAsTAAALEwEAmpwYAAABSElEQVR4nI2QO0vDYBSGv9C5mw7dFEsHQU3tRWrbpBdDQ23TSC8Kbv4DFwdxEl0cHISqi4gg+AMcGsFF/CdCG9Om+dKvtUo7vJLVtOoDB1447zOcQ8gEOsqe1xnyH1CtelhhW2OFWsPJ5C9YrnLE5AqYXIadKx/+WqZSibclddSTtmBvqKBZZUTFEj9VsDPKM00roOkiaKoIKhZgifmniWUrmRcsYROWkMfwJICP4wC6cRnd9RysNTnhEsy4fOUs7d0oxq8cxi8caC0MM5JFO5Spu4RONKN1IlkMb734ahB8PhIM6l60eQHtFUFzCQYvXpupCAYPBP17gv4dAbshMGKr0Bdjly5BX07OG/HggF4QWOcE3TMO5ikHPbQ0NBaC/omHt/xh8X1nlhkHHPR9Dk11ptea48Wpb3UAqXreEj61mfSVnPyz8A0s+58mcDA2swAAAABJRU5ErkJggg=="""),
        schema.Option(display = "Lightning", value = """iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAA1klEQVR4nK2SMQrCQBBFF7H0BIK1M7HRE1hbmYsouUnQi2hl6w20ESQzVoJ1ipQyGdkkgoYku4Iftpv35sOOMR3RBNc5owpB2jXXGL3hQhiehYDhbH6JEs6EIbNw1WDnD1/HQyG4v+GyAcZ+8CUY2LqfsH1KELlhNT0h2NfhQsAYOgVCsG2CC0ESTJ2CvAVue/8X1GNrt8HCsHELGMNGmOCgx3nfLSCIGjaf7FcbnwhjXDumh/Jk5AUXAoLdx+bM6yu/G5QXKYSijMuf4KpBWl5hsOoafAHe1CwuMkCgpAAAAABJRU5ErkJggg=="""),
        schema.Option(display = "Checkmark Circle", value = """iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAABL0lEQVR4nGNgQAdbs3UZtmZOZNiScYVhS8YXKAaxJzBsztBhwAm25bIzbMmcxrA14y/D1sz/OPAfhi2ZUxhWhbJhat6asQ+PRlS8JXMvqiFbMqYTrRlhyGQkP2fgczYcO52Y8J9jex7CO9uztBnAAUaE5vBzc/7//vf3//ZXV/+zbMuGimf0MTBsybxKSHPoudlgzSBQf2sLstxlkP8/Iytuv7MDbBu6zSDQgKoZhD+BvPAJJuB6chJYIUgDSCMBzf8ZtmR8xPACSCHMELyakbwwAV2i/MZ6sEYsfkZ3QS8DOHmCogRNEmQrHpsh0bgtXQuakDKnkJyQQNEPB6BkuSVjDwmadzOcSWNFzQ9gQzInY/MOirNBNmNoRgag5AlKYaAQBqURSDoBsXsRfkYAAOcx7FqgqLUDAAAAAElFTkSuQmCC"""),
        schema.Option(display = "Checkmark", value = """iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAnUlEQVR4nNWRSwoCMRBE62SCG0FEvIKIi66AAwpzs+6cTJEsdIQwTsYfMcGNDb0JVfWaCvB/o9JCuaszGw8wdlBeodKUk43dsDGEroz8uCcop0nkOYO6VZYc6XKEusmIIHMozzAGeC7LyMpFb74LQnz7yhwD3BomlydhyJ89Hi+bNyEZ8kvTso1fU2XG0HhTb06d7OvN6ZL2c2E/nhvi4bFIkTdT4AAAAABJRU5ErkJggg=="""),
        schema.Option(display = "Target", value = """iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAABP0lEQVR4nKVTy04CUQy9G/0TNmDiA27B73OtAurXiEtox7gD/0DXLmbaQMSM6X05j0wgsclN5t7pOe3pw5iGjV7zM0syBZRN7+ar1KPf+qb/TJf1N+UpkDwB8g+QlHoSQbhb4r1FeVDfFtgiv3hH3gLJbIw8jgT6rUBA3jkf5EWNBDSyiyAfQMV5fI8E8W6z4sL7uIzmFc2895H/wF02WhaXmomTk+UD4wrmGWeHwCkTlEeXMcqdscjvehmuGI4lAOKJr4Wsk86m3i5r+ff+S2CDBG3VsRJsJtdJgkW5r7XlCIttB+Jbo62IbdQ+HwJPVsVVbCPQtu9T0ikLg1QladZFwZbkM/hOE6vbA+RFGNOdEqrOSBA06574USZ+Hr6VJ7XUwjLNfWqdy/StkVvgeoXzgU6YVriyzmstWNJcsV8cy3R2aAeVfQAAAABJRU5ErkJggg=="""),
        schema.Option(display = "Chart Up", value = """iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAhklEQVR4nGNgoAnYmtnAsDXzPwomCWzJLMdngPAnv/8gjNuAbbmiDFsznpNnwLZcUYYtGZfAmrZkviLNgG1ImrdmXmfYkiUBDY8GwgZsw6IZB8A0YBvxmrEbsDVjH1TzZYadGWKENGAasDlDB2wIFs3EGUAAkGyAMAEN1DdAmEQN1DeAEgAAy1vJ2cxVS3UAAAAASUVORK5CYII="""),
        schema.Option(display = "Lightbulb", value = """iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAuklEQVR4nLWQPwrCYAzFvzs4OovJ4kkUvYndHKWD4AE61tVjaI/QSTA5gpu6ppEUClL6/Snog7ckeb+EOPcPKeNaGCtheLcmvCrNV0lhYTw2jDpkIThENzeecGclWIa2VzGAEF4CAHhFAYzPZICeF63HAOo4AOrQD/KEC3IvQG8wEcaHD2A9m/ECTMq4EcKmD7Ca9VyKhLAYABRJYWdX3GfTPsBqyQDTKVP99qjwTwDlVndduMx07xv8AEo7TNPXQVHiAAAAAElFTkSuQmCC"""),
        schema.Option(display = "Ghost", value = """iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAA30lEQVR4nJ1SwQ2CQBC8NvQjL3l4h41oSKiACrQKE7uggr2jAuVJCVSBRv2xmzNHIgHvDtBN9rHJzOzMZhlzlJBNLAALDvgyLQCvkWr2LqxVQtJZSNKu5pJOE+Qm9pE/vZHNzi8AWEwJCEmXEQf4NKDgUOngWHWkwQz4GBGgFrRISr1MSu2bbWKuw759s23Vd/A1t9hchy05knotAOsZ2YcNWBsuE0DqZ3InQopxifd/BTjgrbsDB8rmEymzD6kwnb1dYWoJbJUO5goYrPcXfHGctr0P5Yrjsu0rVxyf7Te9OsuOv4HGrwAAAABJRU5ErkJggg=="""),
        schema.Option(display = "Crown", value = """iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAA7UlEQVR4nGNgoBX4f1Nb/+8tja9/b2l+/39Hw5g0zVe0hP7e1rz777bmfxD+e0vjwf8baiJYFf+9rdnw95bmkf+31R3Bmv8zMP29pbEdphnJkD3/99uzgNXc1rD8e1tj99/bmh0gA54gFGnu+Htbcz66Zrj8bc35IDVI/CcMf29prsOlgRD+e1tzLcP/WxoV5Brw/5ZGOcP/O1pOZBsACrf/19V5/97S/EOy829p/v1/S4UPEhO3NK6QYcBlRLwv1V30f5nef9Kw7kKEAcv1Skg3QK8YYcAtDVcyYsAVyQAVUZINuKsjTlL+oBkAACGX8AcwLh2nAAAAAElFTkSuQmCC"""),
        schema.Option(display = "Money", value = """iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAABCElEQVR4nGNgQAfbs7QZtmY2MGzJvMqwJfMZw9bMVQxbMtMYtmQqMRAFtmbuZ9ia+R8rJgpsTnegzAAGBoZPTYL/sWE6GLA5XZphS+ZenF7YkrGQYVUoG3bN29K1GLZkvsSpGY4ztmAaciaNlWFrxjVkhTU3N/3//vfXfxhAM2QSqgFbshLQbfr4+ztcMxYD/jJsTtdHMiBzM7oBm19eAmuc8+goLu/MQDIg4xG6Aq2DTf9///v7/++/f/8ND7dhC9DbyAb8wGYLyHYQALkG04DM7wgDtma+RleADD78/obNBa+QDMg4gcuAb39+/a+4sQFbdJ5AdkEH4fjHwB3I0WhAsgEgPUC9AFY8mXb6FDVPAAAAAElFTkSuQmCC"""),
        schema.Option(display = "USD", value = """iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAABKUlEQVR4nJVTQU5CMRB9G/UuiidQj+EVdEYlJngNv8FA4AK4kOjKFheKS42GHXxu8F0rmujiwzdTEdrfX4KTTNK0ndd5b16BfOjDTWg+h6IBFH1OU9ZV3FAJweiU16C4AU1jaM4CmUJxHe3dVb9Y08OCQjcVd10QRc2ii38RAKlZnMlp+zhuZ6/fbzOAAFCK24MNGMGsg52nyCsMd0JngOLY3jwZXpvLreR5GT36wv/D3tx+PPVeFjrl+LIIYCQURvkDuZx8uRpMsokBd4Wkd49CUV4kLwakMrwqpFANjS/fwZbfQQRjTxnJAgChczTwNEjR2V+fGonr/zaSjH8WYktF90tbWfMdensr7n8wIFzL0/Halpe9YjvEnuIwUVg88usTWUdzzvP4AXhkEFi6q3STAAAAAElFTkSuQmCC"""),
        schema.Option(display = "Potted Plant", value = """iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAA5UlEQVR4nMXQMQ6CMBQG4MfkKAVN9BJeRMDFzaCj9BQI8RQaVw+g1CuIeA5cTRvUsQaiKLQhaRz8k39q3te+ArxiMofnNajzMJiTmNRyiwMOGhA8hchLIMIPIJgXrcd8AZVSew0R3pRD363HoPZdhrTOM3GY4JvkBfZJBrTTsQhE+CgC1HJlgHEdicBhPhEA4KDlO8uQ6u3eShwWXmLH338CxLsD8WL5zQ0pgabw7YD/Uvg/kIcG+oWFiKuUhnoK77AA7VUBFqJdCdAALdQB3f8AoW4prxCgYQlkfrenCmTLTj8ffgL7RtuB0udv3QAAAABJRU5ErkJggg=="""),

        schema.Option(display = "Green Box", value = """iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAGRJREFUeNpi1KsrYSAFsCBzLjZ2Qxj69aW42AxAG/4TDYCKmaD6YCTCJGxsIGCE+wFoL5ocsjhclhHZ08T4gYmBRECyBkas8YDpn6HhByLjgQm/ajQ/QDXgUY2ZOhhJTd4AAQYAmvV1vwf5/YoAAAAASUVORK5CYII="""),
    ]
    layouts = [
        schema.Option(display = "Top and Bottom (With Banner and Divider)", value = "Top"),
        schema.Option(display = "Side by Side (With Icon)", value = "Side"),
        schema.Option(display = "Number Only", value = "Number"),
    ]
    fonts = [
        schema.Option(display = "Small", value = "tom-thumb"),
        schema.Option(display = "Medium (Default)", value = "tb-8"),
        schema.Option(display = "Large", value = "Dina_r400-6"),
        schema.Option(display = "Mono Small", value = "CG-pixel-3x5-mono"),
        schema.Option(display = "Mono Medium", value = "CG-pixel-4x5-mono"),
    ]
    formats = [
        schema.Option(display = "Full", value = "Full"),
        schema.Option(display = "No Comma", value = "Comma"),
        schema.Option(display = "No Dollar Sign", value = "Dollar"),
        schema.Option(display = "No Comma or Dollar Sign", value = "Signs"),
    ]

    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "code",
                icon = "fingerprint",
                name = "Tracker ID",
                desc = "Copy this from your tolta.co single tracker URL",
                default = DEFAULT_CODE,
            ),
            schema.Dropdown(
                id = "layout",
                icon = "grip",
                name = "Layout",
                desc = "The layout of your display",
                options = layouts,
                default = DEFAULT_LAYOUT,
            ),
            schema.Dropdown(
                id = "format",
                icon = "deleteLeft",
                name = "Number Format",
                desc = "How your number is displayed",
                options = formats,
                default = DEFAULT_FORMAT,
            ),
            schema.Dropdown(
                id = "font",
                icon = "font",
                name = "Font",
                desc = "Font used for text and numbers",
                options = fonts,
                default = DEFAULT_FONT,
            ),
            schema.Text(
                id = "banner",
                icon = "message",
                name = "Banner",
                desc = "Text to display in banner",
                default = DEFAULT_BANNER,
            ),
            schema.Dropdown(
                id = "color",
                icon = "eyeDropper",
                name = " Divider Color",
                desc = "The color of the divider",
                options = colors,
                default = DEFAULT_COLOR,
            ),
            schema.Dropdown(
                id = "icon",
                icon = "icons",
                name = "Icon",
                desc = "The icon to display",
                options = icons,
                default = DEFAULT_ICON,
            ),
        ],
    )
