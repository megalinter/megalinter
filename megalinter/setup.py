from setuptools import setup

setup(
    name="megalinter",
    version="0.1",
    description="MegaLinter",
    url="http://github.com/oxsecurity/megalinter",
    author="Nicolas Vuillamy",
    author_email="nicolas.vuillamy@gmail.com",
    license="MIT",
    packages=[
        "megalinter",
        "megalinter.linters",
        "megalinter.reporters",
        "megalinter.tests",
    ],
    install_requires=[
        "gitpython",
        "jsonpickle",
        "multiprocessing_logging",
        "pychalk",
        "pygithub",
        "python-gitlab",
        "azure-devops==6.0.0b4",
        "commentjson",
        "pytablewriter",
        "pyyaml",
        "regex",
        "requests",
        "terminaltables",
        "importlib-metadata>=3.10",
        "fastapi",
    ],
    zip_safe=False,
)
