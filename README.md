# gitrepo-template

<h2 align="center">The absolute template</h2>

<p align="center">
	<a href='https://gitrepo-template.readthedocs.io/en/latest/?badge=latest'>
		<img src='https://readthedocs.org/projects/gitrepo-template/badge/?version=latest' alt='Documentation Status' />
	</a>
</p>


This __gitrepo-template__ can be used as a template to create other GitHub repositories.
It helps users to start a proper repository including files for Community (e.g., license and contributing guideline),
as well as 'professional' documentation built with Sphinx.


---


## Repository options

To let the user choose or tune the repository:

- the .gitignore file is empty;
- the license file is empty.


## Building the documentation

The documentation is built with Sphinx, in the 'docs' folder.
This way, the user can easily connect the GitHub repository to [Read the Docs](https://readthedocs.org/).
The following features have been set:

- build and source folders are separated;
- the [reStructuredText](https://www.sphinx-doc.org/en/master/usage/restructuredtext/index.html) markup language is used to create the documentation;
- the configuration file (conf.py) sets the main basic options.

