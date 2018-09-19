import argparse
import json
import os

from git import Repo


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo_dir', dest='repo_dir', default=None, type=str,
                        help='location of the directory that contains .git file')
    parser.add_argument('--input_dir', dest='input_dir', default=None, type=str,
                        help='directory that contains commit messages')
    return parser.parse_args()


if __name__ == '__main__':
    args = get_args()
    repo_dir = os.path.expanduser(args.repo_dir)
    input_dir = os.path.expanduser(args.input_dir)
    if not os.path.exists(os.path.join(repo_dir, '.git')):
        print('No .git folder found in {}!'.format(repo_dir))
        exit(-1)
    repo = Repo(repo_dir)
    git = repo.git
    if not os.path.exists(input_dir):
        print('`input_dir` does not exist!')
        exit(-1)

    print('Start checking out...')
    num = 1
    diff_folders = os.listdir(input_dir)
    for diff_folder in diff_folders:
        diff_folder = os.path.join(input_dir, diff_folder)
        if os.path.exists(os.path.join(diff_folder, 'description.txt')):
            with open(os.path.join(diff_folder, 'description.txt')) as f:
                description = json.loads(f.read())
            this_hash = description['hash']
            if 'parent_hash' not in description.keys():
                continue
            parent_hash = description['parent_hash']
            changed_files = [file_name[:-5].replace('\\', '/') for file_name in os.listdir(diff_folder) if
                             file_name.endswith('.diff')]
            this_tree = repo.tree(this_hash)
            parent_tree = repo.tree(parent_hash)
            for changed_file in changed_files:
                name, ext = os.path.splitext(changed_file)
                fixed_file_name = '{}_fixed{}'.format(name, ext).replace('/', '\\')
                fixed_file_name = os.path.join(diff_folder, fixed_file_name)
                fixed_file = this_tree[changed_file]
                fixed_file.stream_data(open(fixed_file_name, 'wb'))
                try:
                    parent_file = parent_tree[changed_file]
                    parent_file_name = changed_file.replace('/', '\\')
                    parent_file_name = os.path.join(diff_folder, parent_file_name)
                    parent_file.stream_data(open(parent_file_name, 'wb'))
                except KeyError:
                    pass  # no this file found in parent tree
                print('{} {}'.format(num, changed_file))
                num += 1
