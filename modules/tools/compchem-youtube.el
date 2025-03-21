(use-package ytdl
  :ensure t
  :defer t
  :custom
  (ytdl-download-folder (expand-file-name "~/Downloads/ytdl"))
  (ytdl-music-folder (expand-file-name "~/Music/ytdl"))
  (ytdl-video-folder (expand-file-name "~/Videos/ytdl"))
  :commands (ytdl-download-eshell
             ytdl-download
             ytdl-download-open
             ytdl-download-playlist
             ytdl-show-list))

(provide 'compchem-youtube)

;; compchem-youtube.el ends here
