import argparse
import os
import re
import tkinter as tk
import tkinter.font as font
from tkinter import ttk, filedialog
from tkinter.messagebox import showerror

import yaml
from yaml.parser import ParserError


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--report_file', dest='report_file', default=None,
                        type=str, help='The location of the bug report file')
    return parser.parse_args()


class ReportDisplayer:
    def __init__(self, report_file_path=None):
        root = tk.Tk()
        root.geometry('1050x640')
        root.title('IMChecker Report Displayer')
        # root.resizable(False, False)

        self.api_num = 0
        self.target_api = set()
        self.bugs = []
        self.common_path = None
        self.bug_list_pointer = {}

        self._API_NUM = '#API: {}'
        self._BUGS_NUM = '#Misuse Bugs: {}'

        self.spec_display_str = tk.StringVar()
        self.reason_str = tk.StringVar()
        self.api_num_str = tk.StringVar(value=self._API_NUM.format(''))
        self.bugs_num_str = tk.StringVar(value=self._BUGS_NUM.format(''))
        self.report_file_str = tk.StringVar()

        self.location_re = re.compile(r'(.+ - )*(.+):(.+):(\d+)')

        self.code_font = font.Font(family='Helvetica', size=10)

        main_frame = tk.Frame(root)
        main_frame.grid(row=0, column=0, sticky='nswe')

        # statistics frame
        statistics_frame = tk.Frame(main_frame)
        statistics_frame.pack(side=tk.TOP, fill=tk.X, padx=10, expand=True)
        tk.Label(statistics_frame, text='Statistics').pack(side=tk.LEFT)
        tk.Label(statistics_frame, textvariable=self.api_num_str).pack(side=tk.LEFT, padx=30)
        tk.Label(statistics_frame, textvariable=self.bugs_num_str).pack(side=tk.LEFT)
        tk.Entry(statistics_frame, width=30, state='readonly', textvariable=self.report_file_str).pack(side=tk.RIGHT)
        tk.Label(statistics_frame, text='Report file:').pack(side=tk.RIGHT)
        tk.Button(statistics_frame, text='Load report file', command=self._ask_load_file).pack(side=tk.RIGHT, padx=5)

        # api combobox frame
        api_combobox_frame = tk.Frame(main_frame)
        api_combobox_frame.pack(side=tk.TOP, fill=tk.X, padx=10, pady=10, expand=True)
        self.api_combobox = ttk.Combobox(api_combobox_frame, width=10)
        self.api_combobox.pack(side=tk.LEFT)
        self.api_combobox.bind("<<ComboboxSelected>>", self._on_change_api_combobox)
        self.api_combobox["state"] = "readonly"
        tk.Label(api_combobox_frame, text='Reason:').pack(side=tk.LEFT, padx=(30, 0))
        tk.Entry(api_combobox_frame, textvariable=self.reason_str, width=30).pack(side=tk.LEFT)
        self.spec_display_entry = tk.Entry(api_combobox_frame, width=50, state='readonly',
                                           textvariable=self.spec_display_str)
        self.spec_display_entry.pack(side=tk.RIGHT)
        tk.Label(api_combobox_frame, text='Spec:').pack(side=tk.RIGHT)

        # bug display frame
        bug_display_root = tk.Frame(main_frame, padx=5, pady=5)
        bug_display_root.pack(side=tk.TOP, fill=tk.BOTH)

        # bug list frame
        bug_list_frame = tk.Frame(bug_display_root, highlightbackground='black', highlightcolor='black',
                                  highlightthickness=1, bd=0)
        bug_list_frame.pack(side=tk.LEFT, fill=tk.Y)
        tk.Label(bug_list_frame, text='Bug List').pack(side=tk.TOP)
        bug_list_container = tk.Frame(bug_list_frame)
        bug_list_container.pack(side=tk.TOP, fill=tk.BOTH)
        self.bug_list = tk.Listbox(bug_list_container, width=20, height=30)
        self.bug_list.pack(side=tk.LEFT, expand=True, fill=tk.BOTH)
        self.bug_list.bind('<<ListboxSelect>>', self._on_change_bug_list_selected)
        bug_list_vsb = tk.Scrollbar(bug_list_container, orient='vertical', command=self.bug_list.yview)
        bug_list_hsb = tk.Scrollbar(bug_list_frame, orient='horizontal', command=self.bug_list.xview)
        self.bug_list.config(yscrollcommand=bug_list_vsb.set, xscrollcommand=bug_list_hsb.set)
        bug_list_vsb.pack(side=tk.RIGHT, fill=tk.Y)
        bug_list_hsb.pack(side=tk.BOTTOM, fill=tk.X)

        # misuse display frame
        misuse_display_frame = tk.Frame(bug_display_root, highlightbackground='black', highlightcolor='black',
                                        highlightthickness=1, bd=0)
        misuse_display_frame.pack(side=tk.LEFT, fill=tk.Y)
        tk.Label(misuse_display_frame, text='Bad Usage Display').pack(side=tk.TOP)
        bad_usage_container = tk.Frame(misuse_display_frame)
        bad_usage_container.pack(side=tk.TOP, expand=True, fill=tk.BOTH)
        self.bad_usage_display = tk.Listbox(bad_usage_container, width=50, font=self.code_font)
        self.bad_usage_display.pack(side=tk.LEFT, expand=True, fill=tk.BOTH)
        bad_usage_display_vsb = tk.Scrollbar(bad_usage_container, orient='vertical',
                                             command=self.bad_usage_display.yview)
        bad_usage_display_hsb = tk.Scrollbar(misuse_display_frame, orient='horizontal',
                                             command=self.bad_usage_display.xview)
        self.bad_usage_display.config(yscrollcommand=bad_usage_display_vsb.set,
                                      xscrollcommand=bad_usage_display_hsb.set)
        bad_usage_display_vsb.pack(side=tk.RIGHT, fill=tk.Y)
        bad_usage_display_hsb.pack(side=tk.BOTTOM, fill=tk.X)

        # ref display frame
        ref_display_frame = tk.Frame(bug_display_root, highlightbackground='black', highlightcolor='black',
                                     highlightthickness=1, bd=0)
        ref_display_frame.pack(side=tk.LEFT, fill=tk.Y)
        tk.Label(ref_display_frame, text='Reference Display').pack(side=tk.TOP)
        good_usage_container = tk.Frame(ref_display_frame)
        good_usage_container.pack(side=tk.TOP, expand=True, fill=tk.BOTH)
        self.good_usage_display = tk.Listbox(good_usage_container, width=50, font=self.code_font)
        self.good_usage_display.pack(side=tk.LEFT, expand=True, fill=tk.BOTH)
        good_usage_display_vsb = tk.Scrollbar(good_usage_container, orient='vertical',
                                              command=self.good_usage_display.yview)
        good_usage_display_hsb = tk.Scrollbar(ref_display_frame, orient='horizontal',
                                              command=self.good_usage_display.xview)
        self.good_usage_display.config(yscrollcommand=good_usage_display_vsb.set,
                                       xscrollcommand=good_usage_display_hsb.set)
        good_usage_display_vsb.pack(side=tk.RIGHT, fill=tk.Y)
        good_usage_display_hsb.pack(side=tk.BOTTOM, fill=tk.X)

        # ref list frame
        ref_list_frame = tk.Frame(bug_display_root, highlightbackground='black', highlightcolor='black',
                                  highlightthickness=1, bd=0)
        ref_list_frame.pack(side=tk.LEFT, fill=tk.Y)
        tk.Label(ref_list_frame, text='Ref List').pack(side=tk.TOP)
        ref_list_container = tk.Frame(ref_list_frame)
        ref_list_container.pack(side=tk.TOP, fill=tk.BOTH)
        self.ref_list = tk.Listbox(ref_list_container, width=20, height=30)
        self.ref_list.pack(side=tk.LEFT, expand=True, fill=tk.BOTH)
        self.ref_list.bind('<<ListboxSelect>>', self._on_change_ref_list_selected)
        ref_list_vsb = tk.Scrollbar(ref_list_container, orient='vertical', command=self.ref_list.yview)
        ref_list_hsb = tk.Scrollbar(ref_list_frame, orient='horizontal', command=self.ref_list.xview)
        self.ref_list.config(yscrollcommand=ref_list_vsb.set, xscrollcommand=ref_list_hsb.set)
        ref_list_vsb.pack(side=tk.RIGHT, fill=tk.Y)
        ref_list_hsb.pack(side=tk.BOTTOM, fill=tk.X)

        if report_file_path is not None:
            self._load_report(report_file_path)

        root.mainloop()

    def _ask_load_file(self):
        file_path = filedialog.askopenfilename(title='Select file', initialdir=os.getcwd(),
                                               filetypes=(('YAML files', '*.yaml'), ('all files', '*.*')))
        self.api_num = 0
        self.target_api.clear()
        self.bugs.clear()
        self.common_path = None
        self.bug_list_pointer.clear()
        self.bug_list.delete(0, tk.END)
        self.bad_usage_display.delete(0, tk.END)
        self.good_usage_display.delete(0, tk.END)
        self.ref_list.delete(0, tk.END)

        try:
            if file_path == '':
                return
            self._load_report(file_path)
        except ParserError:
            showerror('Error', 'YAML file parser error! Please check your file!')
            return

    def _load_report(self, report_file_path):
        report_file_path = os.path.abspath(report_file_path)
        if not os.path.exists(report_file_path):
            print('No such file!')
            raise FileNotFoundError
        with open(report_file_path) as f:
            full_report = yaml.load(f.read())
        paths = []
        for bug in full_report:
            bug = bug['Bug']
            bug['Spec'] = re.sub(r'[\'|\"]', '', bug['Spec'])
            bug['Index'] = len(self.bugs)
            for e in bug['Error']:
                paths.append(e)
            for g in bug['Good']:
                paths.append(g)
            self.target_api.add(bug['API'])
            self.bugs.append(bug)
        self.api_num = len(self.target_api)
        self.common_path = os.path.commonpath(paths)
        starting_index = len(self.common_path) + 1 if self.common_path is not None and len(
            self.common_path) > 0 else 0
        for bug in self.bugs:
            error_short = []
            good_short = []
            if bug['Error'] is not None:
                for e in bug['Error']:
                    error_short.append(e[starting_index:])
            if bug['Good'] is not None:
                for g in bug['Good']:
                    good_short.append(g[starting_index:])
            bug['Error'] = error_short
            bug['Good'] = good_short
        self.api_num_str.set(self._API_NUM.format(len(self.target_api)))
        self.bugs_num_str.set(self._BUGS_NUM.format(len(self.bugs)))
        self.report_file_str.set(report_file_path)
        self.api_combobox['values'] = list(self.target_api)

    def _on_change_api_combobox(self, evt):
        w = evt.widget
        index = int(w.current())
        bug_f_name = w['values'][index]
        self.bug_list_pointer.clear()
        self.bug_list.delete(0, tk.END)
        self.bad_usage_display.delete(0, tk.END)
        self.good_usage_display.delete(0, tk.END)
        self.ref_list.delete(0, tk.END)
        filtered_bug_list = [b for b in filter(lambda x: x['API'] == bug_f_name, self.bugs)]
        for b in filtered_bug_list:
            for e in b['Error']:
                self.bug_list_pointer[self.bug_list.size()] = b['Index']
                self.bug_list.insert(tk.END, '{} - {}'.format(b['Type'], e))

    def _on_change_bug_list_selected(self, evt):
        w = evt.widget
        try:
            index = int(w.curselection()[0])
        except IndexError:
            return
        value = w.get(index)
        re_result = self.location_re.findall(value)
        if len(re_result) != 1:
            return
        _, file_location, function_location, num_of_line = re_result[0]
        try:
            num_of_line = int(num_of_line)
        except ValueError:
            return
        start_line = num_of_line - 10 if num_of_line > 10 else 0
        bug_actual_index = self.bug_list_pointer[index]
        actual_bug = self.bugs[bug_actual_index]
        self.reason_str.set(actual_bug['Reason'])
        self.spec_display_str.set(actual_bug['Spec'])
        self.bad_usage_display.delete(0, tk.END)
        self.good_usage_display.delete(0, tk.END)
        self.ref_list.delete(0, tk.END)
        for g in actual_bug['Good']:
            self.ref_list.insert(tk.END, g)
        try:
            with open(os.path.join(self.common_path, file_location)) as f:
                self.bad_usage_display.insert(tk.END, '...')
                for i, line in enumerate(f):
                    if i < start_line:
                        continue
                    if i > num_of_line + 20:
                        break
                    self.bad_usage_display.insert(tk.END, line)
                    if i == num_of_line - 1:
                        self.bad_usage_display.itemconfig(tk.END, bg='red')
                self.bad_usage_display.insert(tk.END, '...')
        except FileNotFoundError:
            showerror('Error', 'Wrong project root!')

    def _on_change_ref_list_selected(self, evt):
        w = evt.widget
        try:
            index = int(w.curselection()[0])
        except IndexError:
            return
        value = w.get(index)
        re_result = self.location_re.findall(value)
        if len(re_result) != 1:
            return
        _, file_location, function_location, num_of_line = re_result[0]
        try:
            num_of_line = int(num_of_line)
        except ValueError:
            return
        start_line = num_of_line - 10 if num_of_line > 10 else 0
        self.good_usage_display.delete(0, tk.END)
        with open(os.path.join(self.common_path, file_location)) as f:
            self.good_usage_display.insert(tk.END, '...')
            for i, line in enumerate(f):
                if i < start_line:
                    continue
                if i > num_of_line + 20:
                    break
                self.good_usage_display.insert(tk.END, line)
                if i == num_of_line - 1:
                    self.good_usage_display.itemconfig(tk.END, bg='green')
            self.good_usage_display.insert(tk.END, '...')


if __name__ == '__main__':
    args = get_args()
    report_displayer = ReportDisplayer(args.report_file)
