(require 'treemacs)
(require 'ert)
(require 'el-mock)

;; treemacs--maybe-filter-dotfiles
(progn
  (ert-deftest filter-dotfiles//do-nothing-when-dotfiles-are-shown ()
    (with-mock (stub treemacs--current-root => "~/")
               (let ((treemacs-show-hidden-files t)
                     (input '("~/.A" "~/B/C" "~/.A/B" "~/.A/.B/.C")))
                 (should (equal input (treemacs--maybe-filter-dotfiles input))))))

  (ert-deftest filter-dotfiles//do-nothing-for-nulls ()
    (with-mock (stub treemacs--current-root => "~/")
               (let ((treemacs-show-hidden-files nil))
                 (should (null (treemacs--maybe-filter-dotfiles nil))))))

  (ert-deftest filter-dotfiles//do-nothing-for-empty-input ()
    (with-mock (stub treemacs--current-root => "~/")
               (let ((treemacs-show-hidden-files nil))
                 (should (null (treemacs--maybe-filter-dotfiles '()))))))

  (ert-deftest filter-dotfiles//filter-single-dotfile ()
    (with-mock (stub treemacs--current-root => "~/")
               (let ((treemacs-show-hidden-files nil)
                     (input '("~/A/B/C/D/.d")))
                 (should (null (treemacs--maybe-filter-dotfiles input))))))

  (ert-deftest filter-dotfiles//filter-dotfile-based-on-parent ()
    (with-mock (stub treemacs--current-root => "~/")
               (let ((treemacs-show-hidden-files nil)
                     (input '("~/A/B/C/.D/d")))
                 (should (null (treemacs--maybe-filter-dotfiles input))))))

  (ert-deftest filter-dotfiles//dont-filter-dotfile-above-root ()
    (with-mock (stub treemacs--current-root => "~/.A/B")
               (let ((treemacs-show-hidden-files nil)
                     (input '("~/.A/B/C/d")))
                 (should (equal input (treemacs--maybe-filter-dotfiles input))))))

  (ert-deftest filter-dotfiles//filter-long-input ()
    (with-mock (stub treemacs--current-root => "~/.A/B")
               (let ((treemacs-show-hidden-files nil)
                     (input '("~/.A/B/C/d" "~/.A/B/.C/D/E" "~/.A/B/C/.d" "~/.A/B/C/D/E")))
                 (should (equal '("~/.A/B/C/d" "~/.A/B/C/D/E") (treemacs--maybe-filter-dotfiles input)))))))

;; treemacs--add-to-cache
(progn
  (ert-deftest add-to-dirs-cache//add-single-item ()
    (let ((parent "~/A")
          (child  "~/A/B")
          (treemacs--open-dirs-cache nil))
      (treemacs--add-to-cache parent child)
      (should (equal `((,parent ,child)) treemacs--open-dirs-cache))))

  (ert-deftest add-to-dirs-cache//add-two-same-parent-items ()
    (let ((parent "~/A")
          (child1 "~/A/B1")
          (child2 "~/A/B2")
          (treemacs--open-dirs-cache nil))
      (treemacs--add-to-cache parent child1)
      (treemacs--add-to-cache parent child2)
      (should (equal `((,parent ,child2 ,child1)) treemacs--open-dirs-cache))))

  (ert-deftest add-to-dirs-cache//add-two-different-parent-items ()
    (let ((parent1 "~/A1")
          (parent2 "~/A2")
          (child1  "~/A/B1")
          (child2  "~/A/B2")
          (treemacs--open-dirs-cache nil))
      (treemacs--add-to-cache parent1 child1)
      (treemacs--add-to-cache parent2 child2)
      (should (equal `((,parent2 ,child2) (,parent1 ,child1)) treemacs--open-dirs-cache))))

  (ert-deftest add-to-dirs-cache//add-new-child-to-cache-with-multiple-items ()
    (let ((parent1 "~/A1")
          (parent2 "~/A2")
          (child1  "~/A/B1")
          (child11 "~/A/B11")
          (child2  "~/A/B2")
          (treemacs--open-dirs-cache nil))
      (treemacs--add-to-cache parent1 child1)
      (treemacs--add-to-cache parent2 child2)
      (treemacs--add-to-cache parent1 child11)
      (should (equal `((,parent2 ,child2) (,parent1 ,child11 ,child1)) treemacs--open-dirs-cache)))))
