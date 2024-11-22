import os

def get_folder_content(base_folder, exclude_folders, exclude_files, exclude_extensions):
    content = []
    for root, dirs, files in os.walk(base_folder):
        # Exclude specified folders
        dirs[:] = [d for d in dirs if d not in exclude_folders]
        for file in files:
            if file not in exclude_files and not any(file.endswith(ext) for ext in exclude_extensions):
                file_path = os.path.join(root, file)
                relative_path = os.path.relpath(file_path, base_folder)
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    file_content = f.read()
                content.append(f"New file: {relative_path}\n{file_content}")
    return content

base_folder = os.getcwd()
exclude_folders = ['venv', '.git', '.pio', '.vscode', 'data', 'assets']
exclude_files = ['requirements.txt', 'all.txt', 'all_code.py', '.gitignore']
exclude_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.ipynb']

content = get_folder_content(base_folder, exclude_folders, exclude_files, exclude_extensions)

with open('all.txt', 'w') as f:
    for item in content:
        f.write("%s\n\n" % item)  # Add an extra line space between different files