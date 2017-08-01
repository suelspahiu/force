import PropTypes from 'prop-types'
import React from 'react'
import BidStatus from './BidStatus'
import block from 'bem-cn'
import get from 'lodash.get'
import titleAndYear from 'desktop/apps/auction2/utils/titleAndYear'
import { connect } from 'react-redux'

function MasonryArtwork (props) {
  const {
    artwork,
    artistDisplay,
    date,
    image,
    isClosed,
    lotLabel,
    title
  } = props

  const b = block('auction2-page-MasonryArtwork')

  return (
    <a href={`/artwork/${artwork.id}`} className={b()}>
      <div>
        <img className={b('image')} src={image} alt={title} />
      </div>

      <div className={b('lot-number')}>
        Lot {lotLabel}
      </div>

      <div className={b('artists')}>
        {artistDisplay}
      </div>

      <div
        className={b('title')}
        dangerouslySetInnerHTML={{
          __html: titleAndYear(title, date)
        }}
      />

      { !isClosed &&
        <div className={b('bid-status')}>
          <BidStatus
            artworkItem={artwork}
          />
        </div> }
    </a>
  )
}

MasonryArtwork.propTypes = {
  artwork: PropTypes.object.isRequired,
  date: PropTypes.string.isRequired,
  image: PropTypes.string.isRequired,
  isClosed: PropTypes.bool.isRequired,
  lotLabel: PropTypes.string.isRequired,
  artistDisplay: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired
}

const mapStateToProps = (state, props) => {
  const { artwork } = props
  const image = get(artwork, 'artwork.images.0.image_medium', '/images/missing_image.png')
  const { artists } = artwork.artwork
  const artistDisplay = artists && artists.length > 0
    ? artists.map((aa) => aa.name).join(', ')
    : ''

  return {
    date: artwork.artwork.date,
    image,
    isClosed: state.app.auction.isClosed(),
    lotLabel: artwork.lot_label,
    artistDisplay,
    title: artwork.artwork.title
  }
}

export default connect(
  mapStateToProps
)(MasonryArtwork)

export const test = { MasonryArtwork }