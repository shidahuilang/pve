from core.other import *
import requests
from flask import stream_with_context, Response, send_from_directory, Flask, request, render_template
import os

# app = Flask(__name__)


# host_url = f"http://127.0.0.1:5001"

@app.route('/download_page')
def download_page():
    book_details = {
        "book_name": request.args.get("book_name"),
        "media": request.args.get("media"),
        "author": request.args.get("author"),
        "category": request.args.get("category"),
        "score": request.args.get("score"),
        "status": request.args.get("status"),
        "word_number": request.args.get("word_number"),
        "abstract": request.args.get("abstract"),
        "book_id": request.args.get("book_id")
    }
    return render_template('download_book.html', **book_details)


@app.route('/download_book')
def download_books():
    book_id = request.args.get("bookId", "")
    book_name = request.args.get("bookName", "")
    media = request.args.get("media", "")
    author = request.args.get("author", "")
    category = request.args.get("category", "")
    score = request.args.get("score", "")
    status = request.args.get("status", "")
    word_number = request.args.get("word_number", "")
    abstract = request.args.get("abstract", "")
    key = request.args.get("key", "")
    host_url = f"http://127.0.0.1:{request.environ.get('SERVER_PORT')}"
    url = f"{host_url}/detail?bookId={book_id}"
    res = requests.get(url).json()["data"]["chapterListWithVolume"]

    total_chapters = sum(len(volume) for volume in res)
    downloaded_chapters = 0

    os.makedirs("books", exist_ok=True)
    file_path = f"books/{book_name}.txt"
    with open(file_path, "w", encoding="utf-8") as f:
        f.write("")

    def generate():
        nonlocal downloaded_chapters
        for volume in res:
            for chapter in volume:
                title = chapter["title"]
                item_id = chapter["itemId"]
                url = f"{host_url}/reader?item_id={item_id}&key={key}?device=download"
                content = requests.get(url).json()["content"]

                with open(file_path, "a", encoding="utf-8") as f:
                    f.write(title + "\n" + content + "\n")

                downloaded_chapters += 1
                progress = (downloaded_chapters / total_chapters) * 100
                yield f"data:{progress:.2f}\n\n"

        yield f"data:complete\n\n"

    return Response(stream_with_context(generate()), content_type='text/event-stream')


@app.route('/download_book/<filename>')
def download_file(filename):
    print(filename)
    return send_from_directory('../books', filename, as_attachment=True)


# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5002)
