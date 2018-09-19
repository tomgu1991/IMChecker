import argparse
import os
import re

import yaml

CMPOP = {'==', '!=', '>=', '<=', '>', '<'}
CMPOP_RE = re.compile(r'({})'.format('|'.join(CMPOP)))


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--full_spec_file', dest='full_spec_file', default='../../spec_list/cwe/cwe.yaml',
                        type=str, help='The location of the full spec file')
    parser.add_argument('--define_file', dest='define_file', default=None,
                        type=str, help='The location of the macro define file')
    return parser.parse_args()


def _check_exist_cmpop(string_to_check):
    return len(CMPOP_RE.findall(string_to_check)) == 1


def _get_opposite_cmpop(cmpop):
    if cmpop == '==':
        return '!='
    if cmpop == '!=':
        return '=='
    if cmpop == '>=':
        return '<'
    if cmpop == '<=':
        return '>'
    if cmpop == '>':
        return '<='
    if cmpop == '<':
        return '>='
    return None


def _get_opposite_eh(eh):
    if not _check_exist_cmpop(eh):
        return eh
    find_result = CMPOP_RE.findall(eh)
    if len(find_result) != 1:
        return eh
    return eh.replace(find_result[0], _get_opposite_cmpop(find_result[0]))


def translate_spec_item(spec_item, define=None):
    if define is None:
        define = {}
    result = []
    assert 'Target' in spec_item.keys()
    f_name_re = re.compile(r'(.+)\(.*\)')
    f_name = f_name_re.findall(spec_item['Target'])
    assert len(f_name) == 1
    f_name = f_name[0]
    define_keys_re = re.compile(r'({})'.format('|'.join(define.keys()))) if len(define.items()) > 0 else None

    ref_func = []
    ref_func_buf = []
    if 'Ref' in spec_item.keys():
        for ref in spec_item['Ref']:
            ref_func_name = f_name_re.findall(ref)
            assert len(ref_func_name) == 1
            ref_func_buf.append(ref_func_name[0])

    pre = []
    if 'Pre' in spec_item.keys():
        for pre_cond in spec_item['Pre']:
            pre_cond = re.sub(r'\s', '', pre_cond)
            find_result = define_keys_re.findall(pre_cond) if define_keys_re is not None else []
            if len(find_result) > 0:
                for item in find_result:
                    pre_cond = pre_cond.replace(item, define[item])
            pre.append(pre_cond.strip(';').replace('\'', ''))

    post = []
    post_detail = []
    if 'Post' in spec_item.keys():
        if spec_item['Post'] is not None:
            for post_cond in spec_item['Post']:
                post_cond = re.sub(r'\s', '', post_cond)
                find_result = define_keys_re.findall(post_cond) if define_keys_re is not None else None
                if find_result is not None and len(find_result) > 0:
                    for r in find_result:
                        post_cond = post_cond.replace(r, define[r])
                post_str = post_cond.strip(';').replace('\'', '')
                if ',' in post_str:
                    eh, action = post_str.split(',')
                    for ref in ref_func_buf:
                        if ref in action:
                            ref_func.append(ref)
                            ref_func_buf.remove(ref)
                            break
                    if len(CMPOP_RE.findall(eh)) != 1:
                        continue
                    this_post = {'eh': eh, 'action': action}
                    filtered_result = [x for x in filter(lambda x: x['eh'] == eh, post_detail)]
                    if len(filtered_result) == 0:
                        post.append(post_str)
                        post_detail.append(this_post)
                    else:
                        post = [p for p in filter(lambda x: not x.startwith(eh), post)]
                        post.append(post_str)
                        post_detail = [p for p in filter(lambda x: not p['eh'] == eh, post_detail)]
                        post_detail.append(this_post)
                        opposite_eh = _get_opposite_eh(eh)
                        post = [p for p in filter(lambda x: not x.startwith(opposite_eh), post)]
                        post_detail = [p for p in filter(lambda x: not p['eh'] == opposite_eh, post_detail)]
                else:
                    if 'CALL' in post_str or 'ENDWITH' in post_str or 'RETURN' in post_str:
                        for ref in ref_func_buf:
                            if ref in post_str:
                                ref_func.append(ref)
                                ref_func_buf.remove(ref)
                                break
                        post_detail.append({'action': post_str})
                        post.append(post_str)
                    else:
                        if _check_exist_cmpop(post_str):
                            filtered_result = [x for x in filter(lambda x: x['eh'] == post_str, post_detail)]
                            if len(filtered_result) == 0:
                                post_detail.append({'eh': post_str})
                                post.append(post_str)

    # done extracting, start translating
    if len(pre) != 0:
        result.append('{}: {}: {}'.format('IPC', f_name, '; '.join(pre)))

    if len(ref_func) == 0:
        if 'Post' in spec_item.keys():
            if len(post) == 0:
                spec_type = 'IRM'
            else:
                spec_type = 'IRC'
            if len(post) == 0 or len(post) == 2:
                result.append('{}: {}: {}'.format(spec_type, f_name, '; '.join(post)))
            else:
                raise TypeError
    else:
        assert len(post) > 0
        ref_re = re.compile(r'({}:)'.format('|'.join(ref_func).replace('|', ':|')))
        for post_cond in post:
            if len(ref_re.findall(post_cond)) == 0 and 'RETURN' in post_cond:
                if ',' not in post_cond:
                    raise TypeError
                eh, action = post_cond.split(',')
                opposite_eh = _get_opposite_eh(eh)
                action = '{}; {}, {}'.format(opposite_eh, eh, action)
                result.append('{}: {}: {}'.format('IRC', f_name, action))
                continue
            if 'ENDWITH' in post_cond:
                result.append('{}: {}: {}'.format('ICR', f_name, post_cond.split(',')[-1].strip()))
            elif 'CALL' in post_cond:
                components = post_cond.split(',')
                if len(components) == 1:
                    result.append('{}: {}: {}'.format('ICS', f_name, post_cond))
                else:
                    result.append('{}: {}: {}'.format('ICC', f_name, post_cond.replace(',', ';')))
            else:
                raise TypeError
    return result


def load_define(define_file_path):
    if define_file_path is None:
        return {}
    define = {}
    if not os.path.exists(define_file_path):
        print('Load define: No such file!')
        raise FileNotFoundError
    with open(define_file_path) as define_f:
        for line in define_f:
            components = re.split(r'\s', line)
            components = [c for c in filter(lambda x: len(x) != 0, components)]
            if len(components) < 3:
                print('Load define: Wrong line: {}'.format(line))
                continue
            _, key, value = components[0:3]
            define[key] = value
    return define


def main_func(full_spec_file, define_file):
    if not os.path.exists(full_spec_file):
        print('No such file!')
        exit(-1)
    spec_file_location = os.path.abspath(full_spec_file)
    output_location, spec_file_name = os.path.split(spec_file_location)
    spec_file_name = os.path.splitext(spec_file_name)[0]
    with open(spec_file_location) as f:
        spec_list = yaml.load(f.read())
    translated_spec_list = []
    define_dict = load_define(define_file)
    for spec in spec_list:
        try:
            translated_spec_list.extend(translate_spec_item(spec['Spec'], define_dict))
        except TypeError:
            print('Wrong type: {}'.format(spec))
    translated_spec_set = set(translated_spec_list)
    result_path = '.audited_{}.txt'.format(spec_file_name)
    with open(os.path.join(output_location, result_path), 'w') as f:
        f.write('\n'.join(translated_spec_set))
        # f.write(yaml.dump(translated_spec_list, allow_unicode=True, default_flow_style=False))

    print("The audited spec file is in " + result_path)
    return result_path


if __name__ == '__main__':
    args = get_args()
    main_func(args.full_spec_file, args.define_file)
