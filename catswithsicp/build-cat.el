(defun build-unluckylisp-cats ()
  "Update index.org, generate index.html in site-dir, and update index.atom."
  (interactive)
  (let* ((site-dir "/home/akai/prog/user/unluckylisp/unluckylisp-site/catswithsicp/")
         (org-path "/home/akai/prog/user/unluckylisp/org/catswithsicp/index.org")
         (img-dir (concat site-dir "image/"))
         (rss-file (concat site-dir "index.atom"))
         ;; This is where the HTML is born (next to the .org file)
         (generated-html (concat (file-name-sans-extension org-path) ".html"))
         ;; This is where the HTML belongs
         (target-html (concat site-dir "index.html"))
         ;; Get images sorted by newest modification time
         (all-images (sort (directory-files img-dir nil "\\.\\(jpg\\|png\\|webp\\|jpeg\\)$")
                           (lambda (a b)
                             (time-less-p (nth 5 (file-attributes (concat img-dir b)))
                                          (nth 5 (file-attributes (concat img-dir a))))))))

    (make-directory (file-name-directory org-path) t)
    (make-directory site-dir t)

    ;; 1. Generate the index.org file
    (with-temp-file org-path
      (insert "#+OPTIONS: toc:nil num:nil author:nil creator:nil title:nil\n")
      (insert "#+LANGUAGE: en\n")
      (insert "#+HTML_HEAD: <meta charset=\"utf-8\">\n")
      (insert "#+HTML_HEAD: <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n")
      (insert "#+HTML_HEAD: <link rel=\"stylesheet\" href=\"/css/style.css\">\n")
      (insert "#+HTML_HEAD: <link rel=\"icon\" type=\"image/png\" href=\"https://unluckylisp.com/favicon.png\">\n")
      (insert "#+HTML_HEAD: <link rel=\"alternate\" type=\"application/atom+xml\" href=\"/catswithsicp/index.atom\" title=\"cats with sicp\">\n")
      (insert "#+HTML_HEAD: <meta name=\"fediverse:creator\" content=\"@wizardbook@mastodon.social\">\n")
      (insert "#+HTML_HEAD: <link rel=\"me\" href=\"https://mastodon.social/@wizardbook\" />\n")
      (insert "#+HTML_HEAD: <meta property=\"og:title\" content=\"unluckylisp\">\n")
      (insert "#+HTML_HEAD: <meta property=\"og:description\" content=\"A site about wizards and programming.\">\n")
      (insert "#+HTML_HEAD: <meta property=\"og:url\" content=\"https://unluckylisp.com/catswithsicp/\">\n")
      (insert "#+HTML_HEAD: <meta property=\"og:type\" content=\"website\">\n")
      (insert "#+TITLE: cats with sicp\n\n")
      (insert "#+BEGIN_EXPORT html\n")
      (insert "<div class=\"pixel-frame\">\n<header class=\"main-header\">\n")
      (insert "  <a href=\"/\" class=\"header-logo\"></a>\n  <h2>CATS WITH SICP</h2>\n</header>\n")
      (insert "<div class=\"outline-text-2\">\nCATS WITH SICP CATS WITH SICP CATS WITH SICCATS WITH SICP CATS WITH SICP CATS WITH SICCATS WITH SICP CATS WITH SICP CATS WITH SICCATS WITH SICP CATS WITH SICP CATS WITH SICCATS WITH SICP CATS WITH SICP CATS WITH SICCATS WITH SICP CATS WITH SICP CATS WITH SICCATS WITH SICP CATS WITH SICP CATS WITH SICCATS WITH SICP CATS WITH SICP CATS WITH SICCATS WITH SICP CATS WITH SICP CATS WITH SICCATS WITH SICP CATS WITH SICP CATS WITH SICCATS WITH SICP CATS WITH SICP CATS WITH SICCATS WITH SICP CATS WITH SICP CATS WITH SICCATS WITH SICP CATS WITH SICP CATS WITH SICCATS WITH SICP CATS WITH SICP CATS WITH SICCATS WITH SICP CATS WITH SICP CATS WITH SICP</div><br>\n")
      (dolist (img all-images)
        (insert (format "<img src=\"/catswithsicp/image/%s\">\n" img)))
      (insert "\n#+END_EXPORT"))

    ;; 2. Generate the HTML file then MOVE it
    (with-current-buffer (find-file-noselect org-path)
      (org-html-export-to-html)
      (kill-buffer))
    
    (if (file-exists-p generated-html)
        (rename-file generated-html target-html t)
      (error "HTML was not generated!"))

    ;; 3. Generate Atom RSS Feed
    (with-temp-file rss-file
      (insert "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n")
      (insert "  <title>cats with sicp</title>\n")
      (insert "  <link href=\"https://unluckylisp.com/catswithsicp/\"/>\n")
      (insert (format "  <updated>%s</updated>\n" (format-time-string "%Y-%m-%dT%H:%M:%SZ" nil t)))
      (dolist (img (seq-take all-images 15))
        (let ((file-time (format-time-string "%Y-%m-%dT%H:%M:%SZ" 
                                             (nth 5 (file-attributes (concat img-dir img))) t)))
          (insert "  <entry>\n")
          (insert (format "    <title>%s</title>\n" img))
          (insert (format "    <link href=\"https://unluckylisp.com/catswithsicp/image/%s\"/>\n" img))
          (insert (format "    <id>https://unluckylisp.com/catswithsicp/image/%s</id>\n" img))
          (insert (format "    <updated>%s</updated>\n" file-time))
          (insert "    <content type=\"html\"><![CDATA[")
          (insert (format "<img src=\"https://unluckylisp.com/catswithsicp/image/%s\">" img))
          (insert "]]></content>\n  </entry>\n")))
      (insert "</feed>"))
    (message "Meow! index.html is now in %s" site-dir)))
